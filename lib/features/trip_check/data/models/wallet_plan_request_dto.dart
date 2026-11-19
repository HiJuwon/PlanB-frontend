// POST /api/v1/plans/wallet, PATCH /api/v1/plans/wallet/{planId} 요청 바디
// - TripCheckDraft(앱 상태) -> 서버 스펙으로 변환
// - 값이 없으면 키를 빼고 보낸다 (임시저장 시 미입력 필드)
//
// TODO(서버 enum 반영 후): 서버가 피그마 기준으로 enum을 맞춰주면
//   1) 아래 매핑 함수들의 null 반환 제거 예정.
//   2) travelStyle이 배열로 바뀌면 전체 전송으로 변경 예정.

import 'package:plan_b/features/trip_check/data/models/accommodation_type.dart';
import 'package:plan_b/features/trip_check/data/models/companion_type.dart';
import 'package:plan_b/features/trip_check/data/models/flight_preference.dart';
import 'package:plan_b/features/trip_check/data/models/travel_style.dart';
import 'package:plan_b/features/trip_check/data/models/trip_check_draft.dart';
import 'package:plan_b/features/trip_check/presentation/widgets/segmented_chip.dart';

class WalletPlanRequestDto {
  const WalletPlanRequestDto({required this.draft, required this.isDraft});

  final TripCheckDraft draft;
  final bool isDraft; // true: 임시저장, false: 최종 제출

  Map<String, dynamic> toJson() {
    final period = draft.travelPeriod;
    final flights = draft.flightPreferences;
    final airline = flights[FlightPreference.airline];
    final route = flights[FlightPreference.route];
    final tripWay = flights[FlightPreference.tripWay];

    final memberType = draft.companionType == null ? null : _member(draft.companionType!);
    // 임시: 서버가 단일 값이라 처음 선택한 스타일만 전송 (Set은 선택 순서 유지)
    final style = draft.travelStyles.firstOrNull;
    // 임시: 서버 enum에 없는 숙소 유형은 제외
    final lodgingTypes = draft.accommodationTypes.map(_lodging).nonNulls.toList();
    final maxManwon = draft.maxBudget?.maxManwon;

    return {
      'common': {
        'isDraft': isDraft,
        if (period != null) 'startDate': _date(period.start),
        if (period != null) 'endDate': _date(period.end),
        if (draft.peopleCount != null) 'memberCount': draft.peopleCount,
        if (memberType != null) 'memberType': memberType,
        if (style != null) 'travelStyle': _style(style),
        if (lodgingTypes.isNotEmpty) 'lodgingTypes': lodgingTypes,
        if (airline != null)
          'flightType': airline == SegmentedChipSide.left ? 'MAJOR' : 'LOW_COST',
        if (route != null)
          'flightRoute': route == SegmentedChipSide.left ? 'DIRECT' : 'TRANSFER',
        if (tripWay != null) 'isRoundFlight': tripWay == SegmentedChipSide.left,
        // 지갑 기준은 식비 입력이 없지만 서버 최종 제출 시 필수값이라 0을 전송
        'foodBudget': 0,
      },
      // TODO(서버): '400만원 이상'(상한 없음)일 때 보낼 값 미정 (현재 미전송 처리함.)
      if (maxManwon != null) 'totalBudget': maxManwon * 10000,
    };
  }

  /// yyyy-MM-dd
  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // 임시: business/group은 서버 enum 반영 전까지 null(미전송)
  static String? _member(CompanionType type) => switch (type) {
        CompanionType.solo => 'ALONE',
        CompanionType.family => 'FAMILY',
        CompanionType.friends => 'FRIEND',
        CompanionType.couple => 'COUPLE',
        CompanionType.business => null,
        CompanionType.group => null,
      };

  static String _style(TravelStyle style) => switch (style) {
        TravelStyle.activity => 'ACTIVITY',
        TravelStyle.scenery => 'SCENERY',
        TravelStyle.landmark => 'LANDMARK',
        TravelStyle.food => 'FOOD_TOUR',
        TravelStyle.relaxation => 'RELAXATION',
        TravelStyle.artCulture => 'ART_CULTURE',
      };

  // 임시: pension/poolVilla는 서버 enum 반영 전까지 null(제외)
  static String? _lodging(AccommodationType type) => switch (type) {
        AccommodationType.hotel => 'HOTEL',
        AccommodationType.hostel => 'HOSTEL',
        AccommodationType.pension => null,
        AccommodationType.poolVilla => null,
        AccommodationType.resort => 'RESORT',
      };
}
