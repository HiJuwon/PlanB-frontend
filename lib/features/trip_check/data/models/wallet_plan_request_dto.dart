// POST /api/v1/plans/wallet 요청 바디
// - TripCheckDraft(앱 상태) -> 서버 스펙으로 변환
// - 값이 없으면 키를 빼고 보낸다 (임시저장 시 미입력 필드)

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

    // TODO(서버): travelStyle이 단일 값이라 첫 번째 선택만 전송 (서버에서 수정되면 앱에서도 반영할 예정)
    final style = TravelStyle.values.where(draft.travelStyles.contains).firstOrNull;

    final lodgingTypes = draft.accommodationTypes.map(_lodging).toList();
    final memberType = draft.companionType == null ? null : _member(draft.companionType!);
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
        // foodBudget: 목표 기준 플로우 전용이라 보내지 않음
      },
      // TODO: '400만원 이상'(상한 없음)은 현재 null -> 서버에서 수정되면 반영해야 함
      if (maxManwon != null) 'totalBudget': maxManwon * 10000,
    };
  }

  /// yyyy-MM-dd
  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // TODO(서버): business/group은 서버 enum에 없음 (현재 null 미전송.)
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

  // TODO(서버): 펜션/풀빌라 매핑 임시값 (서버에서 수정해주면 반영할 예정)
  static String _lodging(AccommodationType type) => switch (type) {
        AccommodationType.hotel => 'HOTEL',
        AccommodationType.hostel => 'HOSTEL',
        AccommodationType.pension => 'GUESTHOUSE',
        AccommodationType.poolVilla => 'RENTAL',
        AccommodationType.resort => 'RESORT',
      };
}