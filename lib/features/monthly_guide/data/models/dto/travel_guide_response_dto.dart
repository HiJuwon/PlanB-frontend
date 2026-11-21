import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:plan_b/features/monthly_guide/data/models/monthly_guide.dart';
import 'package:plan_b/features/monthly_guide/data/models/monthly_period_type.dart';
import 'package:plan_b/features/monthly_guide/data/models/monthly_todo.dart';
import 'package:plan_b/features/monthly_guide/data/models/monthly_todo_type.dart';

part 'travel_guide_response_dto.freezed.dart';
part 'travel_guide_response_dto.g.dart';

/// GET /api/v1/guides/{guideId}
@freezed
class TravelGuideResponseDto with _$TravelGuideResponseDto {
  const factory TravelGuideResponseDto({
    int? dDay,                      // 여행 시작일까지 남은 일수
    num? totalCost,                 // 목표 총 예산
    int? remainingMonths,           // 이번 기간 포함 남은 기간 수
    num? monthlySavingAmount,       // 월 저축 목표 금액
    num? accumulatedSavingAmount,   // 누적 저축 목표 금액
    TravelGuidePeriodDto? period,   // 이번 기간
  }) = _TravelGuideResponseDto;

  factory TravelGuideResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TravelGuideResponseDtoFromJson(json);
}

/// 기간 1개 (이번 기간)
@freezed
class TravelGuidePeriodDto with _$TravelGuidePeriodDto {
  const factory TravelGuidePeriodDto({
    String? periodStart,
    String? periodEnd,
    TravelGuideSavingDto? saving, // 저축 목표 (마지막 자투리 기간이면 없음)
    @Default([]) List<TravelGuideTodoDto> todos,
  }) = _TravelGuidePeriodDto;

  factory TravelGuidePeriodDto.fromJson(Map<String, dynamic> json) =>
      _$TravelGuidePeriodDtoFromJson(json);
}

/// 기간별 저축 목표
@freezed
class TravelGuideSavingDto with _$TravelGuideSavingDto {
  const factory TravelGuideSavingDto({
    required int savingId, // 저축 체크 API(PATCH /guides/savings/{savingId})용
    String? periodStart,
    String? periodEnd,
    num? amount,
    @Default(false) bool isCompleted,
  }) = _TravelGuideSavingDto;

  factory TravelGuideSavingDto.fromJson(Map<String, dynamic> json) =>
      _$TravelGuideSavingDtoFromJson(json);
}

/// 준비 항목 1개
@freezed
class TravelGuideTodoDto with _$TravelGuideTodoDto {
  const factory TravelGuideTodoDto({
    required int todoPeriodId, // Todo 체크 API(PATCH /guides/todos/{todoPeriodId})용
    int? todoId,
    int? recommendationDetailId,
    String? detailType, // COURSE / LODGING / FLIGHT
    String? content,
    num? cost,
    @Default(false) bool isCompleted,
  }) = _TravelGuideTodoDto;

  factory TravelGuideTodoDto.fromJson(Map<String, dynamic> json) =>
      _$TravelGuideTodoDtoFromJson(json);
}

// 서버 -> UI 모양 변환

extension TravelGuideResponseDtoMapper on TravelGuideResponseDto {
  /// 조회 API는 이번 기간 하나만 주므로 periods에 이번 기간만 담음
  /// (전체 기간은 타임라인 API 연동 시 채움)
  MonthlyGuide toMonthlyGuide(String planId) {
    final TravelGuidePeriodDto? current = period;
    final DateTime? start = DateTime.tryParse(current?.periodStart ?? '');
    final DateTime? end = DateTime.tryParse(current?.periodEnd ?? '');
    if (current == null || start == null || end == null) {
      throw StateError('가이드 응답에 이번 기간 정보가 없음');
    }

    final TravelGuideSavingDto? saving = current.saving;

    return MonthlyGuide(
      planId: planId,
      daysLeft: dDay ?? 0,
      totalBudget: (totalCost ?? 0).round(),
      currentIndex: 0,
      periods: [
        MonthlyGuidePeriod(
          // 저축 목표가 없으면 마지막 자투리 기간으로 봄 (lessThanMonth는 예산 목표를 숨김)
          type: saving == null
              ? MonthlyPeriodType.lessThanMonth
              : MonthlyPeriodType.regular,
          startDate: start,
          endDate: end,
          remainingMonths: remainingMonths ?? 0,
          budgetTodo: saving == null
              ? null
              : MonthlyTodo(
                  id: 'saving-${saving.savingId}',
                  type: MonthlyTodoType.budget,
                  title: '${_man(saving.amount ?? monthlySavingAmount)}만원 모으기',
                  budgetStatus:
                      '${_man(accumulatedSavingAmount)}만원 / ${_man(totalCost)}만원',
                  isCompleted: saving.isCompleted,
                ),
          reservationTodos: [for (final todo in current.todos) todo.toMonthlyTodo()],
        ),
      ],
    );
  }
}

extension TravelGuideTodoDtoMapper on TravelGuideTodoDto {
  MonthlyTodo toMonthlyTodo() => MonthlyTodo(
        // 저축 id와 겹치지 않도록 접두어를 붙임 (toggleTodo가 전체에서 id로 찾음)
        id: 'todo-$todoPeriodId',
        type: MonthlyTodoType.reservation,
        title: content ?? '',
        caption: cost == null ? null : '약 ${_man(cost)}만원 내외',
        isCompleted: isCompleted,
      );
}

/// 원 -> 만원 (반올림)
int _man(num? won) => ((won ?? 0) / 10000).round();