import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  // 실행할 때 --dart-define=TEST_TOKEN=... 으로 넣은 값
  static const _testToken = String.fromEnvironment('TEST_TOKEN');
  static const _testRefreshToken = String.fromEnvironment('TEST_REFRESH_TOKEN');

  Future<String?> readAccessToken() async {
    final saved = await _storage.read(key: _accessKey);
    if (saved != null) return saved;
    // 로그인 붙이기 전까지 임시로 테스트 토큰 사용
    return _testToken.isEmpty ? null : _testToken;
  }

  Future<String?> readRefreshToken() async {
    final saved = await _storage.read(key: _refreshKey);
    if (saved != null) return saved;
    return _testRefreshToken.isEmpty ? null : _testRefreshToken;
  }

  Future<void> saveAccessToken(String token) =>
    _storage.write(key: _accessKey, value: token);

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<void> clear() => _storage.deleteAll();
}

// 앱 전체에서 Riverpod을 통해 TokenStorage를 꺼내 쓰게 한다
final tokenStorageProvider = Provider((ref) => TokenStorage());