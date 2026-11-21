// 월별 가이드 생성 (같은 플랜에 생성 요청이 두 번 나가지 않도록 관리)

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/auth/auth_provider.dart';
import 'package:plan_b/features/monthly_guide/data/repositories/monthly_guide_repository.dart';

class GuideCreator {
  GuideCreator(this._repository);
  final MonthlyGuideRepository _repository;

  /// confirmedPlanId -> 생성 요청
  final Map<int, Future<int>> _requests = {};

  /// 월별 가이드 생성 (요청 중이거나 이미 만들었으면 그 결과를 그대로 반환)
  /// - 반환: travelGuideId
  Future<int> ensureGuide(int confirmedPlanId) {
    final Future<int>? pending = _requests[confirmedPlanId];
    if (pending != null) return pending;

    final Future<int> request = _repository.createGuide(confirmedPlanId);
    _requests[confirmedPlanId] = request;

    // 실패하면 기록을 지워서 다음 호출에서 재시도할 수 있게
    request.then((_) {}, onError: (Object _) {
      if (identical(_requests[confirmedPlanId], request)) {
        _requests.remove(confirmedPlanId);
      }
    });
    return request;
  }
}

/// autoDispose 아님: 완료 페이지 > 홈 > 가이드 탭으로 이동해도 기록이 유지되도록.
final guideCreatorProvider = Provider<GuideCreator>((ref) {
  // 로그아웃하면 새로 만들어서 이전 계정의 기록을 비움
  ref.watch(authProvider.select((auth) => auth.isLoggedIn));
  return GuideCreator(ref.read(monthlyGuideRepositoryProvider));
});