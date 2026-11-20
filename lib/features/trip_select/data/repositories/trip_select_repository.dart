import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/network/api_request.dart';
import 'package:plan_b/core/network/dio_provider.dart';
import 'package:plan_b/features/trip_select/data/models/dto/plan_detail_response_dto.dart';
import 'package:plan_b/features/trip_select/data/models/trip_basic_info.dart';
import 'package:plan_b/features/trip_select/data/models/dto/recommendation_response_dto.dart';
import 'package:plan_b/features/trip_select/data/models/trip_plan.dart';
import 'package:plan_b/features/trip_select/data/models/budget_level.dart';

class TripSelectRepository {
  TripSelectRepository(this._dio);
  final Dio _dio;

  /// AI 추천 생성은 오래 걸려서 이 요청만 응답 대기 시간을 늘림 (기본 60초)
  static const Duration _recommendationTimeout = Duration(minutes: 10);

  /// 플랜 기본 정보 조회 (여행 고르기 상단의 여행 기본 정보 섹션)
  Future<TripBasicInfo> getPlanBasicInfo(int planId) {
    return apiRequest(
      () => _dio.get('/api/v1/plans/$planId'),
      (data) => PlanDetailResponseDto.fromJson(data as Map<String, dynamic>)
          .toTripBasicInfo(),
    );
  }

  /// 지갑 기준 AI 여행지 추천 생성 (1~3순위)
  Future<List<TripPlan>> createWalletRecommendations(int planId) {
    return apiRequest(
      () => _dio.post(
        '/api/v1/plans/$planId/recommendations/wallet',
        options: Options(receiveTimeout: _recommendationTimeout),
      ),
      (data) => RecommendationResponseDto.fromJson(data as Map<String, dynamic>)
          .toWalletTripPlans(),
    );
  }

  /// 지갑 기준 추천 여행지 추가 조회 (4~6순위)
  Future<List<TripPlan>> getMoreWalletRecommendations(int planId) {
    return apiRequest(
      () => _dio.get(
        '/api/v1/plans/$planId/recommendations/wallet/more',
        // 일단 1~3순위와 같은 대기 시간 적용
        options: Options(receiveTimeout: _recommendationTimeout),
      ),
      (data) => RecommendationResponseDto.fromJson(data as Map<String, dynamic>)
          .toWalletTripPlans(),
    );
  }

  /// 목표 기준 AI 예산 추천 생성 (고/중/저 3단계)
  Future<List<BudgetLevelPlan>> createGoalRecommendations(int planId) {
    return apiRequest(
      () => _dio.post(
        '/api/v1/plans/$planId/recommendations/goal',
        options: Options(receiveTimeout: _recommendationTimeout),
      ),
      (data) => RecommendationResponseDto.fromJson(data as Map<String, dynamic>)
          .toGoalBudgetPlans(),
    );
  }
}

final tripSelectRepositoryProvider =
    Provider((ref) => TripSelectRepository(ref.read(dioProvider)));