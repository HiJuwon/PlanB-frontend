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

/// 이번 기간이 1개월 단위 (지난 1 + 이번 + 다가올 2)
MonthlyGuide _regularGuide(String planId) => MonthlyGuide(
      planId: planId,
      daysLeft: 92,
      totalBudget: 2350000,
      currentIndex: 1,
      periods: [
        // 지난 기간
        MonthlyGuidePeriod(
          type: MonthlyPeriodType.regular,
          startDate: DateTime(2026, 4, 6),
          endDate: DateTime(2026, 5, 5),
          remainingMonths: 4,
          budgetTodo: const MonthlyTodo(
            id: 'budget-0',
            type: MonthlyTodoType.budget,
            title: '60만원 모으기',
            budgetStatus: '60만원 / 235만원',
            isCompleted: true,
          ),
          reservationTodos: const [
            MonthlyTodo(
              id: 'reservation-0',
              type: MonthlyTodoType.reservation,
              title: '투어 예약',
              caption: '15-20만원',
              isCompleted: true,
            ),
          ],
        ),

        // 이번 기간
        MonthlyGuidePeriod(
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

        // 다가올 기간
        MonthlyGuidePeriod(
          type: MonthlyPeriodType.regular,
          startDate: DateTime(2026, 6, 6),
          endDate: DateTime(2026, 7, 5),
          remainingMonths: 2,
          budgetTodo: const MonthlyTodo(
            id: 'budget-2',
            type: MonthlyTodoType.budget,
            title: '60만원 모으기',
            budgetStatus: '180만원 / 235만원',
          ),
          reservationTodos: const [
            MonthlyTodo(
              id: 'reservation-5',
              type: MonthlyTodoType.reservation,
              title: '현지 투어 예약',
              caption: '15-20만원',
            ),
          ],
        ),

        // 다가올 기간 - 마지막 자투리 구간 (예산 목표 없음)
        MonthlyGuidePeriod(
          type: MonthlyPeriodType.lessThanMonth,
          startDate: DateTime(2026, 7, 6),
          endDate: DateTime(2026, 7, 25),
          reservationTodos: const [
            MonthlyTodo(
              id: 'reservation-6',
              type: MonthlyTodoType.reservation,
              title: '여행자 보험 가입',
              caption: '약 5만원 내외',
            ),
          ],
        ),
      ],
    );

/// 이번 기간이 여행까지 1개월 미만 (지난 2 + 이번, 이번 기간이 마지막)
/// - 지난 기간에 체크하지 않은 항목이 이번 기간 '지난 항목'으로 넘어온 상태
MonthlyGuide _lessThanMonthGuide(String planId) => MonthlyGuide(
      planId: planId,
      daysLeft: 20,
      totalBudget: 2350000,
      currentIndex: 2,
      periods: [
        // 지난 기간 1: 공항 픽업 예약 미완료 -> 이번 기간으로 넘어옴
        MonthlyGuidePeriod(
          type: MonthlyPeriodType.regular,
          startDate: DateTime(2026, 5, 15),
          endDate: DateTime(2026, 6, 14),
          remainingMonths: 3,
          budgetTodo: const MonthlyTodo(
            id: 'hk-budget-1',
            type: MonthlyTodoType.budget,
            title: '120만원 모으기',
            budgetStatus: '120만원 / 235만원',
            isCompleted: true,
          ),
          reservationTodos: const [
            MonthlyTodo(
              id: 'hk-reservation-1',
              type: MonthlyTodoType.reservation,
              title: '항공권 예매',
              caption: '약 75만원 내외',
              isCompleted: true,
            ),
            MonthlyTodo(
              id: 'hk-reservation-2',
              type: MonthlyTodoType.reservation,
              title: '공항 픽업 예약',
              caption: '약 10만원 내외',
            ),
          ],
        ),

        // 지난 기간 2: 저축 목표 미완료 -> 이번 기간으로 넘어옴
        MonthlyGuidePeriod(
          type: MonthlyPeriodType.regular,
          startDate: DateTime(2026, 6, 15),
          endDate: DateTime(2026, 7, 14),
          remainingMonths: 2,
          budgetTodo: const MonthlyTodo(
            id: 'hk-budget-2',
            type: MonthlyTodoType.budget,
            title: '60만원 모으기',
            budgetStatus: '180만원 / 235만원',
          ),
          reservationTodos: const [
            MonthlyTodo(
              id: 'hk-reservation-3',
              type: MonthlyTodoType.reservation,
              title: '숙소 예약',
              caption: '약 60만원 내외',
              isCompleted: true,
            ),
          ],
        ),

        // 이번 기간 (마지막 자투리 구간)
        MonthlyGuidePeriod(
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
      ],
    );