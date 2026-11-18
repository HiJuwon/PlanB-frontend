import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/auth/session_repository.dart';
import 'package:plan_b/core/storage/token_storage.dart';

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

  /// 로그인 성공 후 받은 PlanB 토큰 저장 > 로그인 상태로 변경
  /// (카카오, 구글 등 로그인 방식별 처리는 features/login에서 하고, 여기는 결과만 받음)
  Future<void> signIn({
    required String accessToken,
    required String refreshToken,
    required bool isNewUser,
  }) async {
    await ref.read(tokenStorageProvider).saveTokens(
          access: accessToken,
          refresh: refreshToken,
        );
    state = AuthState(isLoggedIn: true, isNewUser: isNewUser);
  }

  /// 사용자가 직접 로그아웃
  Future<void> logout() async {
    try {
      await ref.read(sessionRepositoryProvider).logout();
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