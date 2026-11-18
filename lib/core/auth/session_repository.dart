import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/network/dio_provider.dart';

/// 로그인 방식(카카오, 구글 등)과 관계없는 세션 API
class SessionRepository {
  SessionRepository(this._dio);
  final Dio _dio;

  /// 서버에 로그아웃 알림 (리프레시 토큰 무효화 등)
  Future<void> logout() => _dio.post('/api/v1/auth/logout');
}

final sessionRepositoryProvider =
    Provider((ref) => SessionRepository(ref.read(dioProvider)));
