import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:plan_b/core/auth/auth_provider.dart';
import 'package:plan_b/core/env.dart';
import 'package:plan_b/core/storage/token_storage.dart';

import 'package:plan_b/core/config/router.dart';
import 'package:plan_b/core/theme/app_theme.dart';
import 'package:plan_b/shared/widgets/feedback/global_loading/global_loading_host.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  // 카카오 SDK 초기화 (dotenv.load 다음에)
  KakaoSdk.init(nativeAppKey: requireEnv('KAKAO_NATIVE_KEY'));

  // 액세스·리프레시 토큰이 둘 다 저장돼 있으면 로그인 상태로 시작 → 앱을 껐다 켜도 로그인 유지
  // 보안 저장소를 읽지 못하면(플랫폼 오류 등) 토큰은 지우지 않고 로그인 화면부터 시작
  // → 다시 로그인하면 새 토큰으로 덮어써짐
  var hasSession = false;
  try {
    hasSession = await TokenStorage().hasCompleteSession();
  } catch (e) {
    debugPrint('저장된 토큰 확인 실패: $e');
  }


  // Riverpod 사용 : 앱 전체를 ProviderScope로 감쌈
  runApp(ProviderScope(
    overrides: [initialLoggedInProvider.overrideWithValue(hasSession)],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // 내 앱의 roots
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'planB',
      theme: AppTheme.light,  // 앱 전체에 공용 테마 적용
      routerConfig: ref.watch(routerProvider),
      // 전역 로딩 오버레이: 모든 화면 및 모달 위에 표시.
      builder: (context, child) => GlobalLoadingHost(child: child!),
    );
  }
}
