import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/network/api_request.dart';
import 'package:plan_b/core/network/dio_provider.dart';
import 'package:plan_b/features/course/data/models/daily_course.dart';
import 'package:plan_b/features/course/data/models/dto/course_list_response_dto.dart';

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
}

final courseRepositoryProvider =
    Provider((ref) => CourseRepository(ref.read(dioProvider)));