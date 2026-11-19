// 맞춤 여행 체크 플로우 전체가 공유하는 입력 상태
// - 초기화: 인트로(TripCheckPage)에서 시작 버튼을 누를 때 reset() 호출한다

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/features/trip_check/data/models/wallet_plan_request_dto.dart';
import 'package:plan_b/features/trip_check/data/repositories/trip_check_repository.dart';

import 'package:plan_b/features/trip_check/data/models/trip_selection_type.dart';
import 'package:plan_b/features/trip_check/data/models/trip_check_draft.dart';
import 'package:plan_b/features/trip_check/data/models/companion_type.dart';
import 'package:plan_b/features/trip_check/data/models/budget_range.dart';
import 'package:plan_b/features/trip_check/data/models/travel_style.dart';
import 'package:plan_b/features/trip_check/data/models/accommodation_type.dart';
import 'package:plan_b/features/trip_check/data/models/flight_preference.dart';
import 'package:plan_b/features/trip_check/data/models/meal_budget.dart';
import 'package:plan_b/features/trip_check/presentation/widgets/segmented_chip.dart';

class TripCheckDraftNotifier extends Notifier<TripCheckDraft> {
  // 저장 요청 대기열: 앞 요청이 끝나야 다음 요청 시작 (화면이 바뀌어도 유지됨)
  Future<void> _saveQueue = Future<void>.value();

  // 플로우 번호: 새 플로우가 시작되면 증가 -> 이전 플로우의 늦은 응답은 반영하지 않는다
  int _flowId = 0;

  @override
  TripCheckDraft build() {
    _flowId++;
    return const TripCheckDraft();
  }

  /// 플로우 시작 시 전체 초기화
  void reset() {
    _flowId++;
    state = const TripCheckDraft();
  }

  /// 저장된 조건으로 복원 (플래너 '여행 플랜 다시 선택하기' -> 여행 고르기 재진입)
  void restore(TripCheckDraft draft) {
    _flowId++;
    state = draft;
  }

  /// Step 1: 여행 계획 기준 선택
  /// 기준이 바뀌면 이후 단계 입력은 다른 플로우 값이므로 함께 초기화
  void selectTripType(TripSelectionType type) {
    if (state.tripType == type) return;
    _flowId++;
    state = TripCheckDraft(tripType: type);
  }

  // 기본 정보

  // 여행지: 목표 기준 플로우에서만 사용
  void setDestination(String destination) =>
      state = state.copyWith(destination: destination);

  void setTravelPeriod(DateTimeRange period) =>
      state = state.copyWith(travelPeriod: period);

  void setPeopleCount(int? count) =>
      state = state.copyWith(peopleCount: count);

  /// null이면 선택 해제
  void setCompanionType(CompanionType? type) =>
      state = state.copyWith(companionType: type);

  // 지갑 기준 플로우
  void setMaxBudget(BudgetRange budget) =>
      state = state.copyWith(maxBudget: budget);

  /// 지갑 기준 플랜 저장
  /// - planId 없음 -> 생성(POST) / 있음 -> 수정(PATCH)
  /// - isDraft: true -> 단계별 임시저장 / false -> 최종 제출
  /// - 요청은 한 번에 하나씩 순서대로 처리 (진행 중인 POST가 있으면 끝난 뒤 PATCH로 이어짐)
  /// - 실패 시 ApiException을 그대로 던짐 (화면에서 처리)
  Future<void> saveWalletPlan({required bool isDraft}) {
    final flowId = _flowId;
    final run = _saveQueue.then(
      (_) => _saveWalletPlan(isDraft: isDraft, flowId: flowId),
    );
    // 앞 요청이 실패해도 다음 요청은 진행되도록 대기열에는 에러를 남기지 않음
    _saveQueue = run.catchError((Object _) {});
    return run;
  }

  Future<void> _saveWalletPlan({required bool isDraft, required int flowId}) async {
    // 기다리는 사이 새 플로우가 시작됐으면 이전 플로우 저장은 건너뜀
    if (flowId != _flowId) return;

    final repository = ref.read(tripCheckRepositoryProvider);
    // 앞 요청이 끝난 뒤의 state 기준: 앞 요청이 생성했다면 planId가 있어 PATCH로 감
    final request = WalletPlanRequestDto(draft: state, isDraft: isDraft);
    final planId = state.planId;

    final res = planId == null
        ? await repository.createWalletPlan(request)
        : await repository.updateWalletPlan(planId, request);

    // 응답을 기다리는 사이 새 플로우가 시작됐으면 이전 planId를 붙이지 않음
    if (flowId != _flowId) return;

    // 요청 중 사용자가 값을 바꿨을 수 있으니 '현재' state에 planId만 반영
    state = state.copyWith(planId: res.planId);
  }

  // 목표 기준 플로우
  void setMealBudget(MealBudget budget) =>
      state = state.copyWith(mealBudget: budget);

  // 세부 취향

  /// 여행 스타일 선택/해제
  /// 최대 개수를 넘겨 새로 선택하려 하면 바꾸지 않고 false 반환
  bool toggleTravelStyle(TravelStyle style) {
    final current = state.travelStyles;
    if (current.contains(style)) {
      state = state.copyWith(travelStyles: {...current}..remove(style));
      return true;
    }
    if (current.length >= TravelStyle.maxSelection) return false;
    state = state.copyWith(travelStyles: {...current, style});
    return true;
  }

  /// 숙소 유형 선택/해제
  /// 최대 개수를 넘겨 새로 선택하려 하면 바꾸지 않고 false 반환
  bool toggleAccommodationType(AccommodationType type) {
    final current = state.accommodationTypes;
    if (current.contains(type)) {
      state = state.copyWith(accommodationTypes: {...current}..remove(type));
      return true;
    }
    if (current.length >= AccommodationType.maxSelection) return false;
    state = state.copyWith(accommodationTypes: {...current, type});
    return true;
  }

  /// 항공권 유형: 항목별로 왼쪽/오른쪽 선택
  void setFlightPreference(FlightPreference preference, SegmentedChipSide side) =>
      state = state.copyWith(
        flightPreferences: {...state.flightPreferences, preference: side},
      );
}

final tripCheckDraftProvider =
    NotifierProvider<TripCheckDraftNotifier, TripCheckDraft>(
  TripCheckDraftNotifier.new,
);