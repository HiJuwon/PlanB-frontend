// 앱 전체에서 쓸 에러 타입
import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

// 요청을 보내고 > data만 꺼내서 > 원하는 모델로 변환
Future<T> apiRequest<T>(
  Future<Response> Function() call,
  T Function(dynamic data) parse,
) async {
  try {
    final res = await call();
    final body = res.data as Map<String, dynamic>;
    return parse(body['data']);
  } on DioException catch (e) {
    final body = e.response?.data;
    // message가 문자열일 때만 사용 (배열 등 다른 형태면 기본 메시지)
    final serverMessage = body is Map && body['message'] is String
        ? body['message'] as String
        : null;
    throw ApiException(
      serverMessage ?? '네트워크 오류가 발생했어요',
      statusCode: e.response?.statusCode,
    );
  }
}