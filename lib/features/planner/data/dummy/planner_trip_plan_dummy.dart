// 나의 여행 플래너 더미데이터 (플래너 API 연동 전 임시임.)

import 'package:flutter/material.dart' show DateTimeRange;

import 'package:plan_b/features/home/data/dummy/trip_plan_summary_dummy.dart';
import 'package:plan_b/features/home/data/models/trip_plan_summary.dart';
import 'package:plan_b/features/planner/data/models/planner_trip_plan.dart';
import 'package:plan_b/features/trip_check/data/models/options/trip_selection_type.dart';
import 'package:plan_b/shared/models/trip_plan_cost_item.dart';

/// 홈 더미에 없는 플래너 전용 값
typedef _PlannerExtra = ({
  TripSelectionType tripType,
  String people,
  String condition,
});

/// 홈 더미 플랜 id별 플래너 값 (지갑 기준 / 목표 기준 플로우가 섞이도록 구성)
const Map<String, _PlannerExtra> _extras = {
  'plan-hu-1': (tripType: TripSelectionType.budget, people: '2명 | 친구', condition: '인당 최대 300만원'),
  'plan-jp-1': (tripType: TripSelectionType.budget, people: '4명 | 가족', condition: '인당 최대 300만원'),
  'plan-jp-2': (tripType: TripSelectionType.goal, people: '2명 | 연인', condition: '1인당 한 끼 최대 3만원 기준'),
  'plan-it-1': (tripType: TripSelectionType.goal, people: '4명 | 가족', condition: '1인당 한 끼 최대 5만원 기준'),
  'plan-hk-1': (tripType: TripSelectionType.budget, people: '1명 | 나홀로', condition: '인당 최대 200만원'),
  'plan-fr-1': (tripType: TripSelectionType.goal, people: '2명 | 연인', condition: '1인당 한 끼 최대 10만원 기준'),
};

const List<int> _highlightCosts = [15, 12, 70]; // 주요 일정 비용 (만원, 태그 순서대로 반복)

/// 날짜 형식
String _formatPeriod(DateTimeRange range) {
  String two(int n) => n.toString().padLeft(2, '0');
  String format(DateTime d) => '${two(d.year % 100)}.${two(d.month)}.${two(d.day)}';
  return '${format(range.start)} - ${format(range.end)}';
}

PlannerTripPlan _fromSummary(TripPlanSummary summary, _PlannerExtra extra) =>
    PlannerTripPlan(
      id: summary.id,
      tripType: extra.tripType,
      title: summary.title,
      period: _formatPeriod(summary.period),
      people: extra.people,
      condition: extra.condition,
      highlights: [
        for (final (i, tag) in summary.tags.indexed)
          TripPlanCostItem(
            title: '$tag 핵심 일정',
            cost: '약 ${_highlightCosts[i % _highlightCosts.length]}만원',
          ),
      ],
      accommodation: const TripPlanCostItem(title: '호텔 더블룸 (6박)', cost: '50-70만원'),
      flight: const TripPlanCostItem(title: '직항 왕복', cost: '60-90만원'),
      totalCost: summary.budget,
    );

final List<PlannerTripPlan> dummyPlannerTripPlans = [
  for (final summary in buildDummyTripPlans())
    if (_extras[summary.id] case final extra?) _fromSummary(summary, extra),
];