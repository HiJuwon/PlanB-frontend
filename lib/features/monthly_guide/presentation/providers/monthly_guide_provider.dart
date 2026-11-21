// 플랜 id로 월별 여행 준비 가이드 조회 + 할 일 완료 체크

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/features/home/data/models/trip_plan_summary.dart';
import 'package:plan_b/features/home/presentation/providers/home_plans_provider.dart';
import 'package:plan_b/features/monthly_guide/data/dummy/monthly_guide_dummy.dart';
import 'package:plan_b/features/monthly_guide/data/models/monthly_guide.dart';
import 'package:plan_b/features/monthly_guide/presentation/providers/guide_creator_provider.dart';
import 'package:plan_b/shared/providers/selected_plan_id_provider.dart';

/// 홈에서 선택한 플랜(confirmedPlanId)의 월별 가이드 id (가이드가 없으면 null)
/// - autoDispose 아님: 의존하는 두 provider도 유지되는 provider라서, read로 읽어도 중간에 폐기되지 않도록
final selectedTravelGuideIdProvider = FutureProvider<int?>((ref) async {
  final String? planId = ref.watch(selectedPlanIdProvider);
  if (planId == null) return null;

  final List<TripPlanSummary> plans = await ref.watch(homePlansProvider.future);
  return plans.where((plan) => plan.id == planId).firstOrNull?.travelGuideId;
});

class MonthlyGuideNotifier
    extends AutoDisposeFamilyAsyncNotifier<MonthlyGuide, String> {
  @override
  Future<MonthlyGuide> build(String planId) async {
    // 가이드 id 확보 (없으면 생성)
    // TODO: 조회 API 연동 시 반환값을 guideId로 받아서 사용
    await _resolveGuideId(planId);

    // TODO: 서버 API 연동 (GET /api/v1/guides/$guideId 로 월별 가이드 조회)
    await Future<void>.delayed(const Duration(milliseconds: 500)); // 임시: 서버 응답 대기 흉내
    final MonthlyGuide? guide = dummyMonthlyGuideOf(planId);

    // 없는 id를 다른 플랜으로 대체하지 않고 오류로 처리 (플래너와 동일)
    if (guide == null) throw StateError('월별 가이드 데이터에 없는 플랜 id: $planId');
    return guide;
  }

  /// 가이드 id 확보: 홈 목록에 있으면 사용, 없으면(생성 실패 / 기존 플랜) 생성
  Future<int> _resolveGuideId(String planId) async {
    // watch가 아닌 read (아래에서 homePlansProvider를 invalidate해도 가이드를 다시 불러오지 않도록)
    final int? savedId = await ref.read(selectedTravelGuideIdProvider.future);
    if (savedId != null) return savedId;

    final int? confirmedPlanId = int.tryParse(planId);
    if (confirmedPlanId == null) throw StateError('확정된 플랜 id가 아님: $planId');

    final int createdId =
        await ref.read(guideCreatorProvider).ensureGuide(confirmedPlanId);

    // 다음 진입 때는 홈 목록에 travelGuideId가 있도록 갱신
    ref.invalidate(homePlansProvider);
    return createdId;
  }

  /// 할 일 완료 체크 토글
  // TODO: 서버 API 연동 (완료 상태 저장 후 갱신된 가이드 응답)
  void toggleTodo(String todoId) {
    final MonthlyGuide? guide = state.valueOrNull;
    if (guide == null) return;

    // 월별 / 타임라인 어느 보기에서 체크해도 같은 할 일이 바뀌도록 전체 기간에서 찾음
    state = AsyncData(guide.toggleTodo(todoId));
  }
}

final monthlyGuideProvider = AsyncNotifierProvider.autoDispose
    .family<MonthlyGuideNotifier, MonthlyGuide, String>(MonthlyGuideNotifier.new);