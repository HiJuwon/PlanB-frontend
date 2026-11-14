// 플랜 id로 나의 여행 플래너 기본 데이터 조회

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/features/planner/data/dummy/planner_trip_plan_dummy.dart';
import 'package:plan_b/features/planner/data/models/planner_trip_plan.dart';

final plannerTripPlanProvider =
    FutureProvider.autoDispose.family<PlannerTripPlan, String>((ref, planId) async {
  // TODO: 서버 API 연동 (planId로 여행 플랜 기본 데이터 조회)
  await Future<void>.delayed(const Duration(milliseconds: 500)); // 임시: 서버 응답 대기 흉내
  return dummyPlannerTripPlans.firstWhere(
    (plan) => plan.id == planId,
    orElse: () => dummyPlannerTripPlans.first, // 임시: 더미에 없는 id면 첫 번째 플랜
  );
});
