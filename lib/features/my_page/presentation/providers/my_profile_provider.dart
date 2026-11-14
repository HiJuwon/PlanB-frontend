// 마이페이지 사용자 프로필 조회 + 이름 변경

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/features/my_page/data/dummy/my_profile_dummy.dart';
import 'package:plan_b/features/my_page/data/models/my_profile.dart';

class MyProfileNotifier extends AsyncNotifier<MyProfile> {
  @override
  Future<MyProfile> build() async {
    // TODO: 서버 API 연동 (로그인한 사용자 프로필 조회)
    await Future<void>.delayed(const Duration(milliseconds: 500)); // 임시: 서버 응답 대기 흉내임.
    return dummyMyProfile;
  }

  /// 이름 변경 (이름 편집 필드에서 저장할 때 호출)
  // TODO: 서버 API 연동 (이름 변경 요청 후 응답으로 갱신, 실패 시 이전 이름으로 되돌림)
  void updateName(String name) {
    final MyProfile? current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(name: name));
  }
}

final myProfileProvider =
    AsyncNotifierProvider<MyProfileNotifier, MyProfile>(MyProfileNotifier.new);