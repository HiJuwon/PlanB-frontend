// 마이페이지 사용자 프로필 조회 + 이름 변경

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/auth/auth_provider.dart';
import 'package:plan_b/core/network/api_request.dart';
import 'package:plan_b/core/storage/profile_storage.dart';
import 'package:plan_b/features/my_page/data/models/dto/nickname_update_request_dto.dart';
import 'package:plan_b/features/my_page/data/models/my_profile.dart';
import 'package:plan_b/features/my_page/data/repositories/my_page_repository.dart';

class MyProfileNotifier extends AsyncNotifier<MyProfile> {
  @override
  Future<MyProfile> build() async {
    // 로그인 상태가 바뀌면 다시 읽음 (로그아웃 > 다른 계정 로그인 시 이전 이름이 남지 않도록)
    ref.watch(authProvider.select((auth) => auth.isLoggedIn));

    // TODO: 프로필 조회 API가 생기면 서버 값으로 교체 (지금은 로그인 때 저장한 값)
    final ProfileStorage storage = ref.read(profileStorageProvider);
    final String? nickname = await storage.readNickname();
    final String? email = await storage.readEmail();

    return MyProfile(name: nickname ?? '', email: email ?? '');
  }

  /// 이름 변경: 화면 먼저 반영 > 서버 요청 > 성공 시 로컬 저장 (실패 시 되돌림)
  Future<void> updateName(String name) async {
    final MyProfile? current = state.valueOrNull;
    if (current == null) return;

    final String? error = NicknameUpdateRequestDto.validate(name);
    if (error != null) throw ApiException(error);

    state = AsyncData(current.copyWith(name: name));

    try {
      await ref.read(myPageRepositoryProvider).updateNickname(name);
    } catch (_) {
      state = AsyncData(current); // 롤백
      rethrow;
    }

    // 서버에는 이미 반영됐으므로 로컬 저장 실패는 사용자에게 에러로 보여주지 않음
    try {
      await ref.read(profileStorageProvider).saveNickname(name);
    } catch (_) {}
  }
}

final myProfileProvider =
    AsyncNotifierProvider<MyProfileNotifier, MyProfile>(MyProfileNotifier.new);