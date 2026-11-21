import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/network/api_request.dart';
import 'package:plan_b/core/network/dio_provider.dart';
import 'package:plan_b/features/course/data/models/daily_course.dart';
import 'package:plan_b/features/course/data/models/dto/course_list_response_dto.dart';
import 'package:plan_b/features/course/data/models/extracted_course.dart';
import 'package:plan_b/features/course/data/models/dto/link_extract_request_dto.dart';
import 'package:plan_b/features/course/data/models/dto/link_extract_response_dto.dart';

class CourseRepository {
  CourseRepository(this._dio);
  final Dio _dio;

  /// 나의 여행 코스 조회 (일일 코스 목록)
  Future<List<DailyCourse>> getMyCourses(int confirmedPlanId) {
    return apiRequest(
      () => _dio.get('/api/v1/plans/confirm/$confirmedPlanId/courses'),
      (data) => CourseListResponseDto.fromJson(data as Map<String, dynamic>)
          .toDailyCourses(),
    );
  }

  /// 추출 요청 응답 대기 시간
  /// AI가 링크 내용을 읽느라 다른 API보다 오래 걸려서 이 요청만 늘림 (기본 60초)
  // TODO: 실제 소요 시간 확인 후 조정
  static const Duration _extractReceiveTimeout = Duration(seconds: 120);

  /// 링크에서 추가할 수 있는 코스를 못 찾았을 때 서버 에러 코드 (400)
  static const String _noCourseFoundCode = 'CONTENT004';

  /// 링크에서 여행 코스 후보 추출 (AI가 링크 내용을 읽고 플랜 예산에 맞는 코스 추출)
  /// 추출된 코스가 없으면 서버가 400(CONTENT004)으로 응답 > 빈 목록으로 처리
  Future<List<ExtractedCourse>> extractCourses(
    int confirmedPlanId,
    List<String> urls,
  ) async {
    try {
      return await apiRequest(
        () => _dio.post(
          '/api/v1/plans/confirm/$confirmedPlanId/contents/extract',
          data: LinkExtractRequestDto(urls: urls).toJson(),
          options: Options(receiveTimeout: _extractReceiveTimeout),
        ),
        (data) => LinkExtractResponseDto.fromJson(data as Map<String, dynamic>)
            .toExtractedCourses(),
      );
    } on ApiException catch (e) {
      if (e.code == _noCourseFoundCode) return const [];
      rethrow;
    }
  }
}

final courseRepositoryProvider =
    Provider((ref) => CourseRepository(ref.read(dioProvider)));