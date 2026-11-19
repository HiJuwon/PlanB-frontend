import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/network/api_request.dart';
import 'package:plan_b/core/network/dio_provider.dart';
import 'package:plan_b/features/trip_check/data/models/wallet_plan_request_dto.dart';
import 'package:plan_b/features/trip_check/data/models/wallet_plan_response_dto.dart';

class TripCheckRepository {
  TripCheckRepository(this._dio);
  final Dio _dio;

  /// 지갑 기준 플랜 생성 (플로우에서 첫 임시저장)
  Future<WalletPlanResponseDto> createWalletPlan(WalletPlanRequestDto request) {
    return apiRequest(
      () => _dio.post('/api/v1/plans/wallet', data: request.toJson()),
      (data) => WalletPlanResponseDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 지갑 기준 플랜 수정 (임시저장 갱신 -> 최종 제출)
  //   - 경로/바디/응답은 배포된 스웨거 기준으로 맞출 것
  Future<WalletPlanResponseDto> updateWalletPlan(
    int planId,
    WalletPlanRequestDto request,
  ) {
    // 임시: PATCH 미배포라 새로 생성하는 것으로 임시 처리. (개발 서버에 플랜이 중복 생성될 수 있음)
    return createWalletPlan(request);

    // TODO(서버 PATCH 배포 후): 임시 처리를 지우고 아래 주석을 살리기
    // return apiRequest(
    //   () => _dio.patch('/api/v1/plans/$planId/wallet', data: request.toJson()),
    //   (data) => WalletPlanResponseDto.fromJson(data as Map<String, dynamic>),
    // );
  }
}

final tripCheckRepositoryProvider =
    Provider((ref) => TripCheckRepository(ref.read(dioProvider)));