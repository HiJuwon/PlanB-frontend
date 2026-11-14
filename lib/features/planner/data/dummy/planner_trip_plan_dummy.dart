// 나의 여행 플래너 더미데이터 (플래너 API 연동 전 임시임.)

import 'package:plan_b/features/planner/data/models/planner_trip_plan.dart';
import 'package:plan_b/features/trip_check/data/models/trip_selection_type.dart';
import 'package:plan_b/shared/models/trip_plan_cost_item.dart';

PlannerTripPlan _plan({
  required String id,
  required TripSelectionType tripType,
  required String condition,
}) =>
    PlannerTripPlan(
      id: id,
      tripType: tripType,
      title: '일본 8월 여행 플랜',
      period: '26.08.10 - 26.08.18',
      people: '4명 | 가족',
      condition: condition,
      highlights: const [
        TripPlanCostItem(title: '도쿄 핵심 명소 투어', cost: '약 15만원'),
        TripPlanCostItem(title: '도쿄 디즈니랜드', cost: '약 12만원'),
        TripPlanCostItem(title: '하코네 온천+로프웨이+유람선', cost: '약 70만원'),
      ],
      accommodation: const TripPlanCostItem(title: '호스텔 패밀리룸 (6박)', cost: '50-70만원'),
      flight: const TripPlanCostItem(title: '저가항공 직행 왕복', cost: '60-90만원'),
      totalCost: '200-270만원',
    );

final List<PlannerTripPlan> dummyPlannerTripPlans = [
  _plan(id: 'b1', tripType: TripSelectionType.budget, condition: '인당 최대 300만원'),
  _plan(id: 'g1', tripType: TripSelectionType.goal, condition: '1인당 한 끼 최대 5만원 기준'),
];
