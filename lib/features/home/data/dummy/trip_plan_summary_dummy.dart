// 홈 화면 더미 여행 플랜 (API 연동 전 UI 확인용)

import 'package:flutter/material.dart' show DateTimeRange;

import 'package:plan_b/features/home/data/models/trip_plan_summary.dart';

List<TripPlanSummary> buildDummyTripPlans() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // 오늘로부터 n일 뒤(음수면 n일 전) 날짜
  DateTime day(int n) => today.add(Duration(days: n));

  DateTimeRange period(int startDay, int endDay) =>
      DateTimeRange(start: day(startDay), end: day(endDay));

  return [
    // 진행중 (어제 시작: D+1)
    TripPlanSummary(
      id: 'plan-hu-1',
      thumbnailUrl: 'https://flagcdn.com/w320/hu.png',
      title: '헝가리 ${day(-1).month}월 여행 플랜',
      destination: '헝가리',
      tags: const ['부다페스트', '근교', '야경크루즈'],
      period: period(-1, 6),
      budget: '180-220만원',
    ),

    // 다가오는 여행 (같은 국가&같은 시기인 플랜 2개 → 생성순 정렬 확인용)
    TripPlanSummary(
      id: 'plan-jp-1',
      thumbnailUrl: 'https://flagcdn.com/w320/jp.png',
      title: '일본 ${day(92).month}월 여행 플랜',
      destination: '일본',
      tags: const ['도쿄', '하코네'],
      period: period(92, 100),
      budget: '200-270만원',
    ),
    TripPlanSummary(
      id: 'plan-jp-2',
      thumbnailUrl: 'https://flagcdn.com/w320/jp.png',
      title: '일본 ${day(92).month}월 여행 플랜 2',
      destination: '일본',
      tags: const ['오사카', '교토'],
      period: period(92, 100),
      budget: '160-180만원',
    ),
    TripPlanSummary(
      id: 'plan-it-1',
      thumbnailUrl: 'https://flagcdn.com/w320/it.png',
      title: '이탈리아 ${day(126).month}월 여행 플랜',
      destination: '이탈리아',
      tags: const ['로마', '피렌체'],
      period: period(126, 133),
      budget: '200-270만원',
    ),

    // 지난 여행
    TripPlanSummary(
      id: 'plan-hk-1',
      thumbnailUrl: 'https://flagcdn.com/w320/hk.png',
      title: '홍콩 ${day(-351).month}월 여행 플랜',
      destination: '홍콩',
      tags: const ['침사추이', '빅토리아피크'],
      period: period(-351, -346),
      budget: '100-120만원',
    ),
    TripPlanSummary(
      id: 'plan-fr-1',
      thumbnailUrl: 'https://flagcdn.com/w320/fr.png',
      title: '프랑스 ${day(-490).month}월 여행 플랜',
      destination: '프랑스',
      tags: const ['파리', '몽생미셸'],
      period: period(-490, -478),
      budget: '240-280만원',
    ),
  ];
}