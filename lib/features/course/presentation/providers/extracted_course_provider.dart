// 붙여넣은 링크에서 예산에 맞는 코스 추출

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/features/course/data/dummy/extracted_course_dummy.dart';
import 'package:plan_b/features/course/data/models/extracted_course.dart';
import 'package:plan_b/shared/providers/selected_plan_id_provider.dart';

/// family 키: 링크 목록을 줄바꿈으로 이은 문자열
String extractedCoursesKeyOf(List<String> links) => links.join('\n');

final extractedCoursesProvider = FutureProvider.autoDispose
    .family<List<ExtractedCourse>, String>((ref, linksKey) async {
  final List<String> links =
      linksKey.split('\n').where((link) => link.isNotEmpty).toList();
  final String? planId = ref.watch(selectedPlanIdProvider);

  // TODO: 서버 API 연동 (planId + 링크 목록 전송 > 플랜 예산에 맞는 코스 추출 결과 응답)
  await Future<void>.delayed(const Duration(milliseconds: 800)); // 임시: 서버 응답 대기 시간 흉내
  if (planId == null) return const [];
  return dummyExtractedCoursesOf(links);
});