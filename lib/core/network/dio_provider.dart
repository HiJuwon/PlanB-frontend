import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plan_b/core/network/auth_interceptor.dart';
import 'package:plan_b/core/storage/token_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final baseOptions = BaseOptions(
    baseUrl: dotenv.env['BASE_URL']!,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json'},
  );

  final dio = Dio(baseOptions);
  dio.interceptors.add(AuthInterceptor(
    storage: ref.read(tokenStorageProvider),
    baseOptions: baseOptions,
    onSessionExpired: () {
      // TODO: 로그인 붙일 때 로그인 화면으로 이동
    },
  ));
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});