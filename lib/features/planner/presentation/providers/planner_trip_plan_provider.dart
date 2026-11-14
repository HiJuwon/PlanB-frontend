// 플랜 id로 나의 여행 플래너 기본 데이터 조회

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/features/planner/data/dummy/planner_trip_plan_dummy.dart';
import 'package:plan_b/features/planner/data/models/planner_trip_plan.dart';

final plannerTripPlanProvider =
    FutureProvider.autoDispose.family<PlannerTripPlan, String>((ref, planId) async {
  // TODO: 서버 API 연동 (planId로 여행 플랜 기본 데이터 조회)
  await Future<void>.delayed(const Duration(milliseconds: 500)); // 임시: 서버 응답 대기 흉내
  final PlannerTripPlan? plan =
    dummyPlannerTripPlans.where((plan) => plan.id == planId).firstOrNull;
  
  // 없는 id를 다른 플랜으로 대체하면 엉뚱한 플랜이 표시&선택되므로 오류로 처리 (페이지 에러 UI)
  if (plan == null) throw StateError('플래너 데이터에 없는 플랜 id: $planId');
  return plan;
});
