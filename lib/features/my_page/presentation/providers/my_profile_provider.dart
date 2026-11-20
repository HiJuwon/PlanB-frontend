// 마이페이지 사용자 프로필 조회 + 이름 변경

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/network/api_request.dart';
import 'package:plan_b/features/my_page/data/dummy/my_profile_dummy.dart';
import 'package:plan_b/features/my_page/data/models/dto/nickname_update_request_dto.dart';
import 'package:plan_b/features/my_page/data/models/my_profile.dart';
import 'package:plan_b/features/my_page/data/repositories/my_page_repository.dart';

class MyProfileNotifier extends AsyncNotifier<MyProfile> {
  @override
  Future<MyProfile> build() async {
    // TODO: 서버 API 연동 (로그인한 사용자 프로필 조회)
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return dummyMyProfile;
  }

  /// 이름 변경 (이름 편집 필드에서 저장할 때 호출)
  /// 실패하면 ApiException을 던짐 (메시지는 화면에서 토스트로 표시)
  Future<void> updateName(String name) async {
    final MyProfile? current = state.valueOrNull;
    if (current == null) return;

    // 서버 규칙과 같은 검사를 먼저 해서 불필요한 요청을 막음
    final String? error = NicknameUpdateRequestDto.validate(name);
    if (error != null) throw ApiException(error);

    state = AsyncData(current.copyWith(name: name));

    try {
      await ref.read(myPageRepositoryProvider).updateNickname(name);
    } catch (_) {
      state = AsyncData(current); // 롤백
      rethrow;
    }
  }
}

final myProfileProvider =
    AsyncNotifierProvider<MyProfileNotifier, MyProfile>(MyProfileNotifier.new);