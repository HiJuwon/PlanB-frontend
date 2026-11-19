// 플랜 다시 선택하기: 플랜 생성 당시의 맞춤 여행 체크 조건 더미데이터
// API 연동 전 임시

import 'package:flutter/material.dart' show DateTimeRange;

import 'package:plan_b/shared/models/destination.dart';
import 'package:plan_b/features/planner/data/models/planner_trip_plan.dart';
import 'package:plan_b/features/trip_check/data/models/budget_range.dart';
import 'package:plan_b/features/trip_check/data/models/companion_type.dart';
import 'package:plan_b/features/trip_check/data/models/meal_budget.dart';
import 'package:plan_b/features/trip_check/data/models/trip_check_draft.dart';
import 'package:plan_b/features/trip_check/data/models/trip_selection_type.dart';

TripCheckDraft dummyTripCheckDraftOf(PlannerTripPlan plan) {
  final bool isBudget = plan.tripType == TripSelectionType.budget;

  return TripCheckDraft(
    tripType: plan.tripType,
    destination: isBudget ? null : Destination.tokyo, // 여행지는 목표 기준 플로우만 표시한다
    travelPeriod: DateTimeRange(
      start: DateTime(2026, 8, 10),
      end: DateTime(2026, 8, 18),
    ),
    peopleCount: 4,
    companionType: CompanionType.family,
    maxBudget: isBudget ? BudgetRange.upTo300 : null,
    mealBudget: isBudget ? null : MealBudget.upTo50k,
  );
}