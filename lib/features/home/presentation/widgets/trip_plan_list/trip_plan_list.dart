// 홈 화면) 여행 플랜 카드 목록

import 'package:flutter/material.dart';

import 'package:plan_b/features/home/data/models/trip_plan_summary.dart';
import 'package:plan_b/features/home/presentation/widgets/trip_plan_list/trip_plan_thumbnail_card.dart';

class TripPlanList extends StatelessWidget {
  const TripPlanList({
    super.key,
    required this.plans,
    required this.isUpcoming,
  });

  final List<TripPlanSummary> plans;
  final bool isUpcoming; // true: 다가오는 여행 (디데이 표시) / false: 지난 여행

  static const int _columns = 2;
  static const double _spacing = 16;    // 카드 좌우 간격
  static const double _runSpacing = 16; // 카드 위아래 간격

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 카드 너비 = (전체 너비 - 간격 합) / 열 개수
        final cardWidth =
            (constraints.maxWidth - _spacing * (_columns - 1)) / _columns;

        return Wrap(
          spacing: _spacing,
          runSpacing: _runSpacing,
          children: [
            for (final plan in plans)
              SizedBox(
                width: cardWidth,
                child: TripPlanThumbnailCard(
                  planId: plan.id,
                  thumbnail: NetworkImage(plan.thumbnailUrl),
                  title: plan.title,
                  period: plan.period,
                  budget: plan.budget,
                  daysLeft: isUpcoming ? plan.daysLeft : null,
                ),
              ),
          ],
        );
      },
    );
  }
}