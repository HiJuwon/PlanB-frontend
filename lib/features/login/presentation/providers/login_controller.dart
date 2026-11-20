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

  /// 로그아웃: 소셜 SDK 로그아웃(실패해도 무시) > PlanB 로그아웃
  /// 어떤 방식으로 로그인했는지 저장하지 않으므로 둘 다 시도.
  Future<void> logout() async {
    await Future.wait([
      _ref.read(kakaoLoginServiceProvider).logout().catchError((_) {}),
      _ref.read(googleLoginServiceProvider).logout().catchError((_) {}),
    ]);
    await _ref.read(authProvider.notifier).logout();
  }

  /// 회원탈퇴: PlanB 서버 탈퇴 -> (성공 시) 소셜 SDK 로그아웃(실패해도 무시)
  /// 서버 탈퇴가 실패했는데 SDK만 로그아웃되는 일이 없도록, SDK는 건드리지 않고 에러를 그대로 던짐
  Future<void> withdraw() async {
    await _ref.read(authProvider.notifier).withdraw();
    await Future.wait([
      _ref.read(kakaoLoginServiceProvider).logout().catchError((_) {}),
      _ref.read(googleLoginServiceProvider).logout().catchError((_) {}),
    ]);
  }
}

final loginControllerProvider = Provider((ref) => LoginController(ref));