import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 로그인 응답으로 받은 프로필(닉네임, 이메일) 로컬 저장
/// TODO: 서버 프로필 조회 API가 생기면 제거 예정
class ProfileStorage {
  final _storage = const FlutterSecureStorage();
  static const _nicknameKey = 'profile_nickname';
  static const _emailKey = 'profile_email';

  Future<String?> readNickname() => _storage.read(key: _nicknameKey);
  Future<String?> readEmail() => _storage.read(key: _emailKey);

  Future<void> saveNickname(String nickname) =>
      _storage.write(key: _nicknameKey, value: nickname);

  /// 로그인 응답 저장 (값이 null이면 이전 계정 값이 남지 않도록 삭제)
  Future<void> saveProfile({String? nickname, String? email}) async {
    await _write(_nicknameKey, nickname);
    await _write(_emailKey, email);
  }

  Future<void> clear() async {
    await _storage.delete(key: _nicknameKey);
    await _storage.delete(key: _emailKey);
  }

  Future<void> _write(String key, String? value) => value == null
      ? _storage.delete(key: key)
      : _storage.write(key: key, value: value);
}

final profileStorageProvider = Provider((ref) => ProfileStorage());