// POST /api/v1/plans/wallet, PATCH /api/v1/plans/wallet/{planId} 요청 바디
// - TripCheckDraft(앱 상태) -> 서버 스펙으로 변환
// - 값이 없으면 키를 빼고 보낸다 (임시저장 시 미입력 필드)

import 'package:plan_b/features/trip_check/data/models/accommodation_type.dart';
import 'package:plan_b/features/trip_check/data/models/budget_range.dart';
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
    final companion = draft.companionType;
    final budget = draft.maxBudget;
    final flights = draft.flightPreferences;
    final airline = flights[FlightPreference.airline];
    final route = flights[FlightPreference.route];
    final tripWay = flights[FlightPreference.tripWay];

    final travelStyles = draft.travelStyles.map(_style).toList();
    final lodgingTypes = draft.accommodationTypes.map(_lodging).toList();

    return {
      'common': {
        'isDraft': isDraft,
        if (period != null) 'startDate': _date(period.start),
        if (period != null) 'endDate': _date(period.end),
        if (draft.peopleCount != null) 'memberCount': draft.peopleCount,
        if (companion != null) 'memberType': _member(companion),
        if (travelStyles.isNotEmpty) 'travelStyles': travelStyles,
        if (lodgingTypes.isNotEmpty) 'lodgingTypes': lodgingTypes,
        if (airline != null)
          'flightType': airline == SegmentedChipSide.left ? 'MAJOR' : 'LOW_COST',
        if (route != null)
          'flightRoute': route == SegmentedChipSide.left ? 'DIRECT' : 'TRANSFER',
        if (tripWay != null) 'isRoundFlight': tripWay == SegmentedChipSide.left,
        // 지갑 기준은 식비 입력이 없지만 서버 최종 제출 시 필수값이라 0을 전송
        'foodBudget': 0,
      },
      if (budget != null) 'budgetRange': _budget(budget),
    };
  }

  /// yyyy-MM-dd
  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _member(CompanionType type) => switch (type) {
        CompanionType.solo => 'ALONE',
        CompanionType.family => 'FAMILY',
        CompanionType.friends => 'FRIEND',
        CompanionType.couple => 'COUPLE',
        CompanionType.business => 'BUSINESS',
        CompanionType.group => 'GROUP',
      };

  static String _budget(BudgetRange budget) => switch (budget) {
        BudgetRange.upTo100 => 'UNDER_100',
        BudgetRange.upTo200 => 'UNDER_200',
        BudgetRange.upTo300 => 'UNDER_300',
        BudgetRange.upTo400 => 'UNDER_400',
        BudgetRange.over400 => 'OVER_400',
      };

  static String _style(TravelStyle style) => switch (style) {
        TravelStyle.activity => 'ACTIVITY',
        TravelStyle.scenery => 'SCENERY',
        TravelStyle.landmark => 'LANDMARK',
        TravelStyle.food => 'FOOD_TOUR',
        TravelStyle.relaxation => 'RELAXATION',
        TravelStyle.artCulture => 'ART_CULTURE',
      };

  static String _lodging(AccommodationType type) => switch (type) {
        AccommodationType.hotel => 'HOTEL',
        AccommodationType.hostel => 'HOSTEL',
        AccommodationType.pension => 'RENTAL',
        AccommodationType.poolVilla => 'POOL_VILLA',
        AccommodationType.resort => 'RESORT',
      };
}