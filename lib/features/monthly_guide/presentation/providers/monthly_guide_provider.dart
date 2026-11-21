// 플랜 id로 월별 여행 준비 가이드 조회 + 할 일 완료 체크

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/network/api_request.dart';
import 'package:plan_b/features/home/data/models/trip_plan_summary.dart';
import 'package:plan_b/features/home/presentation/providers/home_plans_provider.dart';
import 'package:plan_b/features/monthly_guide/data/repositories/monthly_guide_repository.dart';
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
    // 가이드 id 확보 (없으면 생성) 후 조회
    final int guideId = await _resolveGuideId(planId);

    return ref
        .read(monthlyGuideRepositoryProvider)
        .getGuide(guideId: guideId, planId: planId);
  }

  /// 가이드 id 확보: 홈 목록에 있으면 사용, 없으면(생성 실패 / 기존 플랜) 생성
  Future<int> _resolveGuideId(String planId) async {
    // watch가 아닌 read (homePlansProvider가 갱신돼도 가이드를 다시 불러오지 않도록)
    final int? savedId = await ref.read(selectedTravelGuideIdProvider.future);
    if (savedId != null) return savedId;

    final int? confirmedPlanId = int.tryParse(planId);
    if (confirmedPlanId == null) throw StateError('확정된 플랜 id가 아님: $planId');

    try {
      // homePlansProvider 갱신은 GuideCreator가 성공/실패와 관계없이 처리
      return await ref.read(guideCreatorProvider).ensureGuide(confirmedPlanId);
    } on ApiException catch (e) {
      // 이미 생성된 가이드(중복 생성 충돌): 갱신된 홈 목록에서 기존 id를 다시 찾음
      // TODO: 서버의 중복 생성 응답(상태 코드 / 에러 코드)에 맞게 조건 수정
      if (e.statusCode != 409) rethrow;

      final int? existingId = await ref.read(selectedTravelGuideIdProvider.future);
      if (existingId == null) rethrow;
      return existingId;
    }
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