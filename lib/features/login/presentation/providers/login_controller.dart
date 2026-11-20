import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/auth/auth_provider.dart';
import 'package:plan_b/core/storage/profile_storage.dart';
import 'package:plan_b/features/login/data/kakao_login_service.dart';
import 'package:plan_b/features/login/data/google_login_service.dart';
import 'package:plan_b/features/login/data/login_repository.dart';
import 'package:plan_b/features/login/data/models/jwt_login_response.dart';

class LoginController {
  LoginController(this._ref);
  final Ref _ref;

  Future<void> loginWithKakao() async {
    final kakaoToken = await _ref.read(kakaoLoginServiceProvider).login();
    final res =
        await _ref.read(loginRepositoryProvider).loginWithKakao(kakaoToken);
    await _startSession(res);
  }

  Future<void> loginWithGoogle() async {
    final idToken = await _ref.read(googleLoginServiceProvider).login();
    final res =
        await _ref.read(loginRepositoryProvider).loginWithGoogle(idToken);
    await _startSession(res);
  }

  /// 프로필 저장 > 토큰 저장 및 로그인 상태로 변경 (프로필을 먼저 저장해야 로그인 직후 화면에서 바로 읽을 수 있음)
  Future<void> _startSession(JwtLoginResponse res) async {
    await _ref.read(profileStorageProvider).saveProfile(
          nickname: res.nickname,
          email: res.email,
        );
    await _ref.read(authProvider.notifier).signIn(
          accessToken: res.jwtAccessToken,
          refreshToken: res.jwtRefreshToken,
          isNewUser: res.newUser,
        );
  }
}

final loginControllerProvider = Provider((ref) => LoginController(ref));