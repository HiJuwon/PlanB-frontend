import 'package:flutter/material.dart';

import 'package:plan_b/core/theme/app_colors.dart';
import 'package:plan_b/core/theme/app_text_styles.dart';
import 'package:plan_b/features/monthly_guide/data/models/monthly_todo_type.dart';

/// 월별 가이드 할 일 항목의 텍스트 영역
class MonthlyViewItemContent extends StatelessWidget {
  const MonthlyViewItemContent({
    super.key,
    required this.type,
    required this.title,
    this.caption,
    this.budgetStatus,
    this.showBudgetStatus = true,
  });

  final MonthlyTodoType type;
  final String title;
  final String? caption;       // reservation 전용
  final String? budgetStatus;  // budget 전용 (예: "120만원 / 235만원")
  final bool showBudgetStatus; // budget 전용: 목표 누적 줄 표시 여부

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          title,
          style: AppTextStyles.titleSemiBold16.copyWith(
            color: AppColors.gray700,
          ),
        ),
        ..._buildSubContent(),
      ],
    );
  }

  List<Widget> _buildSubContent() {
    switch (type) {
      case MonthlyTodoType.reservation:
        if (caption == null) return const [];
        return [
          Text(
            caption!,
            style: AppTextStyles.captionMedium12.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ];

      case MonthlyTodoType.budget:
        if (!showBudgetStatus || budgetStatus == null) return const [];
        return [_BudgetStatus(status: budgetStatus!)];
    }
  }
}

/// "목표 누적" 라벨 + 누적 금액
class _BudgetStatus extends StatelessWidget {
  const _BudgetStatus({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '목표 누적',
          style: AppTextStyles.captionMedium12.copyWith(
            color: AppColors.gray500,
          ),
        ),
        Text(
          status,
          style: AppTextStyles.captionMedium12.copyWith(
            color: AppColors.gray800,
          ),
        ),
      ],
    );
  }
}