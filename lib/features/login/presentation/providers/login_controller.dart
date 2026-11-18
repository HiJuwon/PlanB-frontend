import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/auth/auth_provider.dart';
import 'package:plan_b/features/login/data/kakao_login_service.dart';
import 'package:plan_b/features/login/data/google_login_service.dart';
import 'package:plan_b/features/login/data/login_repository.dart';

/// 로그인 흐름 조정: 소셜 로그인 > 서버 토큰 교환 > 세션 시작(authProvider)
/// 로그인 방식이 늘어나면 여기에 메서드만 추가 (core/auth는 수정하지 않음)
class LoginController {
  LoginController(this._ref);
  final Ref _ref;

  /// 카카오 로그인 > PlanB 서버 로그인 > 토큰 저장 및 로그인 상태로 변경
  Future<void> loginWithKakao() async {
    final kakaoToken = await _ref.read(kakaoLoginServiceProvider).login();
    final res =
        await _ref.read(loginRepositoryProvider).loginWithKakao(kakaoToken);

    await _ref.read(authProvider.notifier).signIn(
          accessToken: res.jwtAccessToken,
          refreshToken: res.jwtRefreshToken,
          isNewUser: res.newUser,
        );
  }

  /// 구글 로그인 > PlanB 서버 로그인 > 토큰 저장 및 로그인 상태로 변경
  Future<void> loginWithGoogle() async {
    final idToken = await _ref.read(googleLoginServiceProvider).login();
    final res =
        await _ref.read(loginRepositoryProvider).loginWithGoogle(idToken);

    await _ref.read(authProvider.notifier).signIn(
          accessToken: res.jwtAccessToken,
          refreshToken: res.jwtRefreshToken,
          isNewUser: res.newUser,
        );
  }
}

final loginControllerProvider = Provider((ref) => LoginController(ref));
