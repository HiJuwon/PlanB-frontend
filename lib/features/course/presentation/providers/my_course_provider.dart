// 플랜 id로 나의 여행 코스(일일 코스 목록) 조회 + 웹에서 찾은 코스 추가

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/features/course/data/dummy/daily_course_dummy.dart';
import 'package:plan_b/features/course/data/models/daily_course.dart';
import 'package:plan_b/features/course/data/models/extracted_course.dart';
import 'package:plan_b/features/course/data/repositories/course_repository.dart';

class MyCourseNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<DailyCourse>, String> {
  @override
  Future<List<DailyCourse>> build(String planId) async {
    final int? confirmedPlanId = int.tryParse(planId);
    // 숫자가 아니면 조회할 수 없으므로 오류로 처리 (페이지 에러 UI)
    if (confirmedPlanId == null) throw StateError('확정된 플랜 id가 아님: $planId');

    final List<DailyCourse> courses =
        await ref.read(courseRepositoryProvider).getMyCourses(confirmedPlanId);
    return _sortByCost(courses);
  }

  /// 추출된 코스를 내 플랜에 추가 (코스 정보 추출 화면의 '+' 버튼)
  /// - 요청과 목록 갱신을 notifier가 끝까지 처리: 요청 중 화면을 닫아도 성공한 결과가 반영됨
  /// - 실패하면 예외를 그대로 던짐 (화면에서 토스트 처리)
  Future<void> addExtractedCourse(ExtractedCourse course) async {
    // 요청하는 동안에는 구독하는 화면이 없어져도 provider가 정리되지 않도록 유지
    final KeepAliveLink keepAlive = ref.keepAlive();
    try {
      // 첫 조회가 아직 진행 중이면 끝날 때까지 기다림
      // (늦게 끝난 조회 결과가 추가 결과를 덮어쓰지 않도록)
      if (state.isLoading) {
        await future.catchError((_) => const <DailyCourse>[]);
      }

      final List<DailyCourse> updated = await _requestAddCourse(arg, course);
      state = AsyncData(_sortByCost(updated));
    } finally {
      keepAlive.close();
    }
  }

  /// 코스 추가 요청 > 이동 거리 기준으로 반영된 일일 코스 목록 응답
  // TODO: 서버 API 연동 (planId + 추출 코스 전송 > 새 일일 코스 / 기존 일일 코스에 추가 판단 결과 응답)
  Future<List<DailyCourse>> _requestAddCourse(
    String planId,
    ExtractedCourse course,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300)); // 임시: 서버 응답 대기 흉내
    return dummyDailyCoursesWithNewCourse; // 임시: '새 일일 코스로 추가됨' 결과
  }

  /// 일일 코스 정렬: 예상 비용이 낮은 순서
  static List<DailyCourse> _sortByCost(List<DailyCourse> courses) =>
      List.of(courses)..sort((a, b) => a.estimatedCost.compareTo(b.estimatedCost));
}

final myCourseProvider = AsyncNotifierProvider.autoDispose
    .family<MyCourseNotifier, List<DailyCourse>, String>(MyCourseNotifier.new);