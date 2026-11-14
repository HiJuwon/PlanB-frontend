/// 홈 화면 여행 플랜 카드(trip_plan_thumbnail_card)에 표시할 데이터
/// (API 스펙 확정 전이라 UI 기준으로만 구조화했음)

import 'package:flutter/material.dart' show DateTimeRange;

class TripPlanSummary {
  const TripPlanSummary({
    required this.id,
    required this.thumbnailUrl,
    required this.title,
    required this.period,
    required this.budget,
  });

  final String id;              // 플랜 id (플래너 화면 이동용)
  final String thumbnailUrl;    // 썸네일 이미지 URL
  final String title;           // 이탈리아 9월 여행 플랜
  final DateTimeRange period;   // 여행 기간
  final String budget;          // 예산 (표시 형식: '200-270만원')

  /// 여행 시작일까지 남은 일수 (오늘 기준)
  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(period.start.year, period.start.month, period.start.day);
    return start.difference(today).inDays;
  }
}