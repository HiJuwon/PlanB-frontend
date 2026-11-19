import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/network/api_request.dart';
import 'package:plan_b/core/network/dio_provider.dart';
import 'package:plan_b/features/trip_check/data/models/wallet_plan_request_dto.dart';
import 'package:plan_b/features/trip_check/data/models/wallet_plan_response_dto.dart';

class TripCheckRepository {
  TripCheckRepository(this._dio);
  final Dio _dio;

  /// 지갑 기준 온보딩 저장 (isDraft로 임시저장/최종 제출 구분)
  Future<WalletPlanResponseDto> createWalletPlan(WalletPlanRequestDto request) {
    return apiRequest(
      () => _dio.post('/api/v1/plans/wallet', data: request.toJson()),
      (data) => WalletPlanResponseDto.fromJson(data as Map<String, dynamic>),
    );
  }
}

final tripCheckRepositoryProvider =
    Provider((ref) => TripCheckRepository(ref.read(dioProvider)));