// 플랜 id로 나의 여행 코스(일일 코스 목록) 조회 + 웹에서 찾은 코스 추가

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  /// TODO: 코스 추가 API(POST /api/v1/plans/confirm/{confirmedPlanId}/courses) 연동
  ///  - 추출 API 연동 후 course.extractId / course.index로 요청
  ///  - 성공하면 나의 여행 코스를 다시 조회해서 state 갱신
  /// 연동 전에는 조회한 목록(state)을 건드리지 않고 실패로 처리 (화면에서 실패 토스트)
  Future<void> addExtractedCourse(ExtractedCourse course) async {
    throw UnimplementedError('코스 추가 API 연동 전');
  }

  /// 일일 코스 정렬: 예상 비용이 낮은 순서
  static List<DailyCourse> _sortByCost(List<DailyCourse> courses) =>
      List.of(courses)..sort((a, b) => a.estimatedCost.compareTo(b.estimatedCost));
}

final myCourseProvider = AsyncNotifierProvider.autoDispose
    .family<MyCourseNotifier, List<DailyCourse>, String>(MyCourseNotifier.new);