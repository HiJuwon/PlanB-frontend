import 'package:dio/dio.dart';
import 'package:plan_b/core/storage/token_storage.dart';

class AuthInterceptor extends QueuedInterceptor { // Interceptor → QueuedInterceptor (함정 2)
  AuthInterceptor({
    required this.storage,
    required BaseOptions baseOptions,
    this.onSessionExpired,
  }) : _plainDio = Dio(baseOptions); // 인터셉터 없는 별도 Dio

  final TokenStorage storage;
  final Dio _plainDio;
  final void Function()? onSessionExpired; // 로그인 화면 이동 등 (나중에 연결)

  static const _reissuePath = '/api/v1/auth/token/reissue';

  // 요청 직전: 토큰 붙이기
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // 에러 발생: 401이면 재발급 후 재시도
  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final is401 = err.response?.statusCode == 401;
    final alreadyRetried = req.extra['retried'] == true;

    if (!is401 || alreadyRetried) {
      return handler.next(err); // 401이 아니거나 이미 한 번 재시도했으면 그냥 에러로 넘김
    }

    // 앞선 요청이 이미 재발급했으면 그 토큰을 재사용
    final usedToken =
        (req.headers['Authorization'] as String?)?.replaceFirst('Bearer ', '');
    var newToken = await storage.readAccessToken();
    if (newToken == null || newToken == usedToken) {
      newToken = await _reissue();
    }

    // 재발급 실패 = 리프레시 토큰도 만료 -> 로그아웃
    if (newToken == null) {
      await storage.clear();
      onSessionExpired?.call();
      return handler.next(err);
    }

    // 실패했던 요청을 새 토큰으로 다시 보내기
    try {
      req.headers['Authorization'] = 'Bearer $newToken';
      req.extra['retried'] = true;
      final response = await _plainDio.fetch(req);
      handler.resolve(response); // 원래 호출한 쪽은 이 성공 응답을 받음
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<String?> _reissue() async {
    final refreshToken = await storage.readRefreshToken();
    if (refreshToken == null) return null;

    try {
      final res = await _plainDio.post(
        _reissuePath,
        data: {'refreshToken': refreshToken},
      );
      final data = res.data as Map<String, dynamic>;
      final token = (data['access_token'] ?? data['data']?['access_token']) as String?;
      if (token != null) await storage.saveAccessToken(token);
      return token;
    } catch (_) {
      return null;
    }
  }
}