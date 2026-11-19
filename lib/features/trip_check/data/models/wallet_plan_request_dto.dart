// POST /api/v1/plans/wallet, PATCH /api/v1/plans/wallet/{planId} 요청 바디

import 'package:plan_b/features/trip_check/data/models/budget_range.dart';
import 'package:plan_b/features/trip_check/data/models/common_travel_plan_dto.dart';
import 'package:plan_b/features/trip_check/data/models/trip_check_draft.dart';

class WalletPlanRequestDto {
  const WalletPlanRequestDto({required this.draft, required this.isDraft});

  final TripCheckDraft draft;
  final bool isDraft; // true: 임시저장, false: 최종 제출

  Map<String, dynamic> toJson() {
    final budget = draft.maxBudget;

    return {
      'common': CommonTravelPlanDto(
        draft: draft,
        isDraft: isDraft,
        // 지갑 기준은 식비 입력이 없지만 서버 최종 제출 시 필수값이라 0을 전송
        foodBudget: 0,
      ).toJson(),
      if (budget != null) 'budgetRange': _budget(budget),
    };
  }

  static String _budget(BudgetRange budget) => switch (budget) {
        BudgetRange.upTo100 => 'UNDER_100',
        BudgetRange.upTo200 => 'UNDER_200',
        BudgetRange.upTo300 => 'UNDER_300',
        BudgetRange.upTo400 => 'UNDER_400',
        BudgetRange.over400 => 'OVER_400',
      };
}