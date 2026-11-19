import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/network/api_request.dart';
import 'package:plan_b/core/network/dio_provider.dart';
import 'package:plan_b/features/trip_select/data/models/dto/plan_detail_response_dto.dart';
import 'package:plan_b/features/trip_select/data/models/trip_basic_info.dart';

class TripSelectRepository {
  TripSelectRepository(this._dio);
  final Dio _dio;

  /// 플랜 기본 정보 조회 (여행 고르기 상단의 여행 기본 정보 섹션)
  Future<TripBasicInfo> getPlanBasicInfo(int planId) {
    return apiRequest(
      () => _dio.get('/api/v1/plans/$planId'),
      (data) => PlanDetailResponseDto.fromJson(data as Map<String, dynamic>)
          .toTripBasicInfo(),
    );
  }
}

final tripSelectRepositoryProvider =
    Provider((ref) => TripSelectRepository(ref.read(dioProvider)));