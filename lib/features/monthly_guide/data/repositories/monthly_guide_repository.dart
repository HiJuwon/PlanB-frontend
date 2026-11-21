import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/network/api_request.dart';
import 'package:plan_b/core/network/dio_provider.dart';
import 'package:plan_b/features/monthly_guide/data/models/dto/travel_guide_response_dto.dart';
import 'package:plan_b/features/monthly_guide/data/models/monthly_guide.dart';

class MonthlyGuideRepository {
  MonthlyGuideRepository(this._dio);
  final Dio _dio;

  /// 월별 여행 준비 가이드 생성
  /// - confirmId: 확정된 플랜 id (confirmedPlanId)
  /// - 반환: 생성된 가이드 id (travelGuideId) -> 가이드 조회 API의 guideId
  Future<int> createGuide(int confirmId) {
    return apiRequest(
      () => _dio.post('/api/v1/guides/$confirmId'),
      (data) => ((data as Map<String, dynamic>)['travelGuideId'] as num).toInt(),
    );
  }

  /// 월별 여행 준비 가이드 조회 (이번 기간)
  /// - guideId: 가이드 생성 응답 / 홈 목록의 travelGuideId
  /// - planId: 화면 모델에 넣을 플랜 id (selectedPlanIdProvider 값)
  Future<MonthlyGuide> getGuide({
    required int guideId,
    required String planId,
  }) {
    return apiRequest(
      () => _dio.get('/api/v1/guides/$guideId'),
      (data) => TravelGuideResponseDto.fromJson(data as Map<String, dynamic>)
          .toMonthlyGuide(planId),
    );
  }
}

final monthlyGuideRepositoryProvider =
    Provider((ref) => MonthlyGuideRepository(ref.read(dioProvider)));