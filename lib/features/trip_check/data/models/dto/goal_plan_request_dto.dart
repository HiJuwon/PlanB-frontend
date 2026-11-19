// POST /api/v1/plans/goal, PATCH /api/v1/plans/goal/{planId} 요청 바디

import 'package:plan_b/features/trip_check/data/models/dto/common_travel_plan_dto.dart';
import 'package:plan_b/features/trip_check/data/models/options/meal_budget.dart';
import 'package:plan_b/features/trip_check/data/models/trip_check_draft.dart';
import 'package:plan_b/shared/models/destination.dart';

class GoalPlanRequestDto {
  const GoalPlanRequestDto({required this.draft, required this.isDraft});

  final TripCheckDraft draft;
  final bool isDraft; // true: 임시저장, false: 최종 제출

  Map<String, dynamic> toJson() {
    final destination = draft.destination;

    return {
      'common': CommonTravelPlanDto(
        draft: draft,
        isDraft: isDraft,
        foodBudget: _foodBudget(draft.mealBudget),
      ).toJson(),
      if (destination != null) 'destination': _destination(destination),
    };
  }

  /// 1인당 한 끼 식비: 선택지의 상한 금액(원)
  // TODO(서버): '10만원 이상'(상한 없음)일 때 보낼 값 미정임 (현재는 일단 미전송 처리함)
  static int? _foodBudget(MealBudget? budget) => budget?.maxWon;

  /// 서버 여행지 enum (nhaTrang -> NHA_TRANG)
  /// Destination의 @JsonEnum(fieldRename: screamingSnake)와 같은 규칙
  static String _destination(Destination destination) => destination.name
      .replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}')
      .toUpperCase();
}