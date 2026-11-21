// 웹 링크 코스 추출 결과 더미데이터
// TODO: 추출 API 연동 전 임시.

import 'package:plan_b/features/course/data/models/course_category.dart';
import 'package:plan_b/features/course/data/models/extracted_course.dart';

const List<({CourseCategory category, String title, String caption, int cost})> _courses = [
  (
    category: CourseCategory.tour,
    title: '시부야·하라주쿠 감성 투어',
    caption: '메이지 신궁 · 다케시타 거리 · 시부야 스카이 · 쇼핑',
    cost: 80000,
  ),
  (
    category: CourseCategory.accommodation,
    title: '하코네 료칸 온천 숙박',
    caption: '전통 료칸 · 노천 온천 · 가이세키 요리 · 산속 휴식',
    cost: 250000,
  ),
  (
    category: CourseCategory.food,
    title: '쓰키지 시장 먹거리 투어',
    caption: '신선한 스시 · 해산물 덮밥 · 타마고야키 · 길거리 음식',
    cost: 40000,
  ),
];

/// 입력한 링크로 추출 결과 더미 생성 (코스마다 원본 출처를 순서대로 돌아가며 배정)
List<ExtractedCourse> dummyExtractedCoursesOf(List<String> links) {
  if (links.isEmpty) return const [];

  return [
    for (final (i, course) in _courses.indexed)
      ExtractedCourse(
        id: 'extracted-${i + 1}',
        category: course.category,
        title: course.title,
        caption: course.caption,
        sourceUrl: links[i % links.length],
        estimatedCost: course.cost,
      ),
  ];
}