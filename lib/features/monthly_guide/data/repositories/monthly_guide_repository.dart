import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/network/api_request.dart';
import 'package:plan_b/core/network/dio_provider.dart';

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
}

final monthlyGuideRepositoryProvider =
    Provider((ref) => MonthlyGuideRepository(ref.read(dioProvider)));