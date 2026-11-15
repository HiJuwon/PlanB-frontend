// 월별 여행 준비 가이드 더미데이터 (API 연동 전 임시)

import 'package:plan_b/features/monthly_guide/data/models/monthly_guide.dart';
import 'package:plan_b/features/monthly_guide/data/models/monthly_period_type.dart';
import 'package:plan_b/features/monthly_guide/data/models/monthly_todo.dart';
import 'package:plan_b/features/monthly_guide/data/models/monthly_todo_type.dart';
import 'package:plan_b/features/planner/data/dummy/planner_trip_plan_dummy.dart';

const String _lessThanMonthPlanId = 'plan-hk-1';

/// 플랜 id에 해당하는 더미 가이드 (없는 id면 null)
MonthlyGuide? dummyMonthlyGuideOf(String planId) {
  final bool exists = dummyPlannerTripPlans.any((plan) => plan.id == planId);
  if (!exists) return null;

  return planId == _lessThanMonthPlanId
      ? _lessThanMonthGuide(planId)
      : _regularGuide(planId);
}

/// 1개월 단위 기간 (피그마 월별 가이드 화면과 동일)
MonthlyGuide _regularGuide(String planId) => MonthlyGuide(
      planId: planId,
      daysLeft: 92,
      totalBudget: 2350000,
      currentPeriod: MonthlyGuidePeriod(
        type: MonthlyPeriodType.regular,
        startDate: DateTime(2026, 5, 6),
        endDate: DateTime(2026, 6, 5),
        remainingMonths: 3,
        budgetTodo: const MonthlyTodo(
          id: 'budget-1',
          type: MonthlyTodoType.budget,
          title: '60만원 모으기',
          budgetStatus: '120만원 / 235만원',
          isCompleted: true,
        ),
        reservationTodos: const [
          MonthlyTodo(
            id: 'reservation-1',
            type: MonthlyTodoType.reservation,
            title: '항공권 예매',
            caption: '약 75만원 내외',
          ),
          MonthlyTodo(
            id: 'reservation-2',
            type: MonthlyTodoType.reservation,
            title: '숙소 예약',
            caption: '약 60만원 내외',
          ),
        ],
      ),
    );

/// 여행까지 1개월 미만 (지난 항목 있음, 예산 목표 없음)
MonthlyGuide _lessThanMonthGuide(String planId) => MonthlyGuide(
      planId: planId,
      daysLeft: 20,
      totalBudget: 2350000,
      currentPeriod: MonthlyGuidePeriod(
        type: MonthlyPeriodType.lessThanMonth,
        startDate: DateTime(2026, 7, 15),
        endDate: DateTime(2026, 8, 9),
        carryoverTodos: const [
          MonthlyTodo(
            id: 'carryover-budget-1',
            type: MonthlyTodoType.budget,
            title: '60만원 모으기',
          ),
          MonthlyTodo(
            id: 'carryover-1',
            type: MonthlyTodoType.reservation,
            title: '공항 픽업 예약',
            caption: '약 10만원 내외',
          ),
        ],
        reservationTodos: const [
          MonthlyTodo(
            id: 'reservation-3',
            type: MonthlyTodoType.reservation,
            title: '현지 투어 예약',
            caption: '약 30만원 내외',
          ),
          MonthlyTodo(
            id: 'reservation-4',
            type: MonthlyTodoType.reservation,
            title: '여행자 보험 가입',
            caption: '약 5만원 내외',
          ),
        ],
      ),
    );