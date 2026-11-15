import 'package:plan_b/features/monthly_guide/data/models/monthly_period_type.dart';
import 'package:plan_b/features/monthly_guide/data/models/monthly_todo.dart';

/// 월별 가이드 카드 한 장에 해당하는 기간 데이터
class MonthlyGuidePeriod {
  const MonthlyGuidePeriod({
    required this.type,
    required this.startDate,
    required this.endDate,
    this.remainingMonths = 0,
    this.carryoverTodos = const [],
    this.budgetTodo,
    this.reservationTodos = const [],
  });

  final MonthlyPeriodType type;
  final DateTime startDate;
  final DateTime endDate;                  // 기간 마지막 날 (포함)
  final int remainingMonths;               // regular 전용: 현재 기간 포함 남은 기간 수
  final List<MonthlyTodo> carryoverTodos;  // 지난 기간에서 넘어온 항목
  final MonthlyTodo? budgetTodo;           // 이번 기간 저축 목표 (regular 전용)
  final List<MonthlyTodo> reservationTodos; // 이번 기간 준비 항목

  /// 카드 상단 기간 문구 (2026.05.06. ~ 2026.06.05. 형식)
  String get dateRangeLabel {
    String two(int n) => n.toString().padLeft(2, '0');
    String format(DateTime d) => '${d.year}.${two(d.month)}.${two(d.day)}.';
    return '${format(startDate)} ~ ${format(endDate)}';
  }

  /// id가 같은 할 일의 완료 여부를 뒤집은 새 기간 데이터
  MonthlyGuidePeriod toggleTodo(String todoId) {
    MonthlyTodo toggle(MonthlyTodo todo) => todo.id == todoId
        ? todo.copyWith(isCompleted: !todo.isCompleted)
        : todo;

    return MonthlyGuidePeriod(
      type: type,
      startDate: startDate,
      endDate: endDate,
      remainingMonths: remainingMonths,
      carryoverTodos: carryoverTodos.map(toggle).toList(),
      budgetTodo: budgetTodo == null ? null : toggle(budgetTodo!),
      reservationTodos: reservationTodos.map(toggle).toList(),
    );
  }
}

/// 월별 여행 준비 가이드 화면 데이터
class MonthlyGuide {
  const MonthlyGuide({
    required this.planId,
    required this.daysLeft,
    required this.totalBudget,
    required this.currentPeriod,
  });

  final String planId;
  final int daysLeft;      // 여행 시작일까지 남은 일수
  final int totalBudget;   // 목표 총 예산 (원)
  final MonthlyGuidePeriod currentPeriod; // 오늘이 속한 기간

  /// 여행까지 남은 기간: D-n / D-Day / D+n
  String get dDayLabel {
    if (daysLeft > 0) return 'D-$daysLeft';
    if (daysLeft == 0) return 'D-Day';
    return 'D+${-daysLeft}';
  }

  /// 목표 총 예산
  String get totalBudgetLabel => '약 ${(totalBudget / 10000).round()}만원';

  MonthlyGuide copyWith({MonthlyGuidePeriod? currentPeriod}) => MonthlyGuide(
        planId: planId,
        daysLeft: daysLeft,
        totalBudget: totalBudget,
        currentPeriod: currentPeriod ?? this.currentPeriod,
      );
}