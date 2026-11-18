import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/network/api_request.dart';
import 'package:plan_b/core/network/dio_provider.dart';
import 'package:plan_b/features/login/data/models/jwt_login_response.dart';

class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;

  /// 카카오 액세스 토큰 -> PlanB 토큰
  Future<JwtLoginResponse> loginWithKakao(String kakaoAccessToken) async {
    try {
      final res = await _dio.post(
        '/api/v1/auth/login/kakao',
        data: {'token': kakaoAccessToken},
      );
      final body = res.data as Map<String, dynamic>;
      // 응답이 감싸져 있으면 data를, 아니면 body 그대로 사용
      final json = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;
      return JwtLoginResponse.fromJson(json);
    } on DioException catch (e) {
      final body = e.response?.data;
      final message = body is Map ? body['message'] as String? : null;
      throw ApiException(message ?? '로그인에 실패했어요', statusCode: e.response?.statusCode);
    }
  }

  /// 서버에 로그아웃 알림 (리프레시 토큰 무효화 등)
  Future<void> logout() => _dio.post('/api/v1/auth/logout');
}

final authRepositoryProvider =
    Provider((ref) => AuthRepository(ref.read(dioProvider)));