import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/storage/token_storage.dart';
import 'package:plan_b/features/login/data/auth_repository.dart';
import 'package:plan_b/features/login/data/kakao_login_service.dart';

class AuthState {
  const AuthState({required this.isLoggedIn, this.isNewUser = false});

  final bool isLoggedIn;
  final bool isNewUser; // 방금 로그인한 신규 회원인지 (로그인 직후 이동 경로 결정용)
}

/// 앱 시작 시 저장된 토큰이 있었는지 (main에서 override)
final initialLoggedInProvider = Provider<bool>(
  (ref) => throw UnimplementedError('main()에서 overrideWithValue로 넣어야 함'),
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState(isLoggedIn: ref.read(initialLoggedInProvider));

  /// 카카오 로그인 > 서버 로그인 > 토큰 저장 > 상태 변경
  Future<void> loginWithKakao() async {
    final kakaoToken = await ref.read(kakaoLoginServiceProvider).login();
    final res = await ref.read(authRepositoryProvider).loginWithKakao(kakaoToken);

    await ref.read(tokenStorageProvider).saveTokens(
          access: res.jwtAccessToken,
          refresh: res.jwtRefreshToken,
        );
    state = AuthState(isLoggedIn: true, isNewUser: res.newUser);
  }

  /// 사용자가 직접 로그아웃
  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // 서버 요청이 실패해도 앱에서는 로그아웃 처리
    }
    await ref.read(tokenStorageProvider).clear();
    state = const AuthState(isLoggedIn: false);
  }

  /// 리프레시 토큰까지 만료됨 (인터셉터가 토큰을 지운 뒤 호출)
  void sessionExpired() => state = const AuthState(isLoggedIn: false);
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);