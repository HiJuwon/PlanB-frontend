// 플랜 id로 나의 여행 코스(일일 코스 목록) 조회 + 웹에서 찾은 코스 반영

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/features/course/data/dummy/daily_course_dummy.dart';
import 'package:plan_b/features/course/data/models/daily_course.dart';

class MyCourseNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<DailyCourse>, String> {
  @override
  Future<List<DailyCourse>> build(String planId) async {
    // TODO: 서버 API 연동 (planId로 일일 코스 목록 조회)
    await Future<void>.delayed(const Duration(milliseconds: 500)); // 임시: 서버 응답 대기 흉내
    return _sortByCost(dummyDailyCourses);
  }

  /// 코스 정보 추출 결과 반영 (코스 정보 추출 화면에서 호출)
  /// - 새 일일 코스로 만들지 / 기존 일일 코스에 넣을지는 서버가 이동 거리 기준으로 판단한 결과를 받음
  // TODO: 서버 API 연동 (추출 결과 반영 후 갱신된 코스 목록 응답)
  void reflectExtracted(List<DailyCourse> courses) {
    state = AsyncData(_sortByCost(courses));
  }

  /// 일일 코스 정렬: 예상 비용이 낮은 순서
  static List<DailyCourse> _sortByCost(List<DailyCourse> courses) =>
      List.of(courses)..sort((a, b) => a.estimatedCost.compareTo(b.estimatedCost));
}

final myCourseProvider = AsyncNotifierProvider.autoDispose
    .family<MyCourseNotifier, List<DailyCourse>, String>(MyCourseNotifier.new);