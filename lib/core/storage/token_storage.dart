import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  /// 서버가 'Bearer xxx' 형태로 줄 때를 대비해 접두어 제거
  /// (요청 헤더에는 인터셉터가 'Bearer '를 붙임)
  static String _stripBearer(String token) =>
      token.startsWith('Bearer ') ? token.substring(7) : token;

  Future<String?> readAccessToken() async {
    final saved = await _storage.read(key: _accessKey);
    return saved == null ? null : _stripBearer(saved); // 이미 'Bearer'째로 저장된 토큰도 처리
  }

  Future<String?> readRefreshToken() async {
    final saved = await _storage.read(key: _refreshKey);
    return saved == null ? null : _stripBearer(saved);
  }

  Future<void> saveAccessToken(String token) =>
    _storage.write(key: _accessKey, value: _stripBearer(token));

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: _stripBearer(access));
    await _storage.write(key: _refreshKey, value: _stripBearer(refresh));
  }

  Future<void> clear() => _storage.deleteAll();
}

// 앱 전체에서 Riverpod을 통해 TokenStorage를 꺼내 쓰게 한다
final tokenStorageProvider = Provider((ref) => TokenStorage());