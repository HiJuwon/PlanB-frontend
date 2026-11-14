// 나의 여행 코스 더미데이터 (코스 API 연동 전 임시임)

import 'package:plan_b/features/course/data/models/daily_course.dart';

const List<CoursePlace> _hakonePlaces = [
  CoursePlace(title: '하코네 온천', caption: '하코네 유모토 온천'),
  CoursePlace(title: '로프웨이', caption: '하코네 로프웨이'),
  CoursePlace(title: '유람선', caption: '아시노코 유람선'),
];

/// 기본: 여행 플랜 생성 시 만들어진 일일 코스
const List<DailyCourse> dummyDailyCourses = [
  DailyCourse(
    id: 'course-1',
    estimatedCost: 120000,
    places: [
      CoursePlace(title: '도쿄 디즈니랜드', caption: '어트랙션 · 퍼레이드 · 야간 불꽃놀이'),
    ],
  ),
  DailyCourse(
    id: 'course-2',
    estimatedCost: 150000,
    places: [
      CoursePlace(
        title: '도쿄 핵심 명소 투어',
        caption: '아사쿠사 센소지 · 우에노 공원 · 아메요코 시장 · 아키하바라',
      ),
    ],
  ),
  DailyCourse(id: 'course-3', estimatedCost: 700000, places: _hakonePlaces),
];

/// 코스 반영 1) 추출한 코스가 새 일일 코스로 생긴 경우
const List<DailyCourse> dummyDailyCoursesWithNewCourse = [
  ...dummyDailyCourses,
  DailyCourse(
    id: 'course-new-1',
    isNew: true,
    estimatedCost: 80000,
    places: [
      CoursePlace(
        title: '시부야·하라주쿠 감성 투어',
        caption: '메이지 신궁 · 다케시타 거리 · 시부야 스카이 · 쇼핑',
      ),
    ],
  ),
];

/// 코스 반영 2) 추출한 장소가 기존 일일 코스(하코네)에 추가된 경우
const List<DailyCourse> dummyDailyCoursesWithAddedPlace = [
  DailyCourse(
    id: 'course-1',
    estimatedCost: 120000,
    places: [
      CoursePlace(title: '도쿄 디즈니랜드', caption: '어트랙션 · 퍼레이드 · 야간 불꽃놀이'),
    ],
  ),
  DailyCourse(
    id: 'course-2',
    estimatedCost: 150000,
    places: [
      CoursePlace(
        title: '도쿄 핵심 명소 투어',
        caption: '아사쿠사 센소지 · 우에노 공원 · 아메요코 시장 · 아키하바라',
      ),
    ],
  ),
  DailyCourse(
    id: 'course-3',
    estimatedCost: 700000,
    places: [
      ..._hakonePlaces,
      CoursePlace(
        title: '하코네 료칸',
        caption: '전통 료칸 · 노천 온천 · 가이세키 요리 · 산속 휴식',
        isAdded: true,
      ),
    ],
  ),
];