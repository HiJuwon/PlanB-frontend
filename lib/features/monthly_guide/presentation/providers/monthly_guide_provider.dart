// 플랜 id로 월별 여행 준비 가이드 조회 + 할 일 완료 체크

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/features/monthly_guide/data/dummy/monthly_guide_dummy.dart';
import 'package:plan_b/features/monthly_guide/data/models/monthly_guide.dart';

class MonthlyGuideNotifier
    extends AutoDisposeFamilyAsyncNotifier<MonthlyGuide, String> {
  @override
  Future<MonthlyGuide> build(String planId) async {
    // TODO: 서버 API 연동 (planId로 월별 가이드 조회)
    await Future<void>.delayed(const Duration(milliseconds: 500)); // 임시: 서버 응답 대기 흉내
    final MonthlyGuide? guide = dummyMonthlyGuideOf(planId);

    // 없는 id를 다른 플랜으로 대체하지 않고 오류로 처리 (플래너와 동일)
    if (guide == null) throw StateError('월별 가이드 데이터에 없는 플랜 id: $planId');
    return guide;
  }

  /// 할 일 완료 체크 토글
  // TODO: 서버 API 연동 (완료 상태 저장 후 갱신된 가이드 응답)
  void toggleTodo(String todoId) {
    final MonthlyGuide? guide = state.valueOrNull;
    if (guide == null) return;

    state = AsyncData(
      guide.copyWith(currentPeriod: guide.currentPeriod.toggleTodo(todoId)),
    );
  }
}

final monthlyGuideProvider = AsyncNotifierProvider.autoDispose
    .family<MonthlyGuideNotifier, MonthlyGuide, String>(MonthlyGuideNotifier.new);