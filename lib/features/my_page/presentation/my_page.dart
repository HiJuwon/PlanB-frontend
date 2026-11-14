// 마이페이지

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/theme/app_colors.dart';
import 'package:plan_b/core/theme/app_text_styles.dart';
import 'package:plan_b/features/my_page/data/models/my_profile.dart';
import 'package:plan_b/features/my_page/presentation/providers/my_profile_provider.dart';
import 'package:plan_b/features/my_page/presentation/providers/push_notification_provider.dart';
import 'package:plan_b/features/my_page/presentation/widgets/app_settings/app_settings_section.dart';
import 'package:plan_b/features/my_page/presentation/widgets/my_page_modals.dart';
import 'package:plan_b/features/my_page/presentation/widgets/profile_section/profile_section.dart';
import 'package:plan_b/shared/widgets/app_page.dart';
import 'package:plan_b/shared/widgets/feedback/global_loading/show_global_loading.dart';
import 'package:plan_b/shared/widgets/header/title_header.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  static const double _profileTopGap = 24;    // 헤더 ~ 프로필 간격
  static const double _settingsTopGap = 70;   // 프로필 ~ 앱 설정 간격
  static const double _contentBottomGap = 40; // 마지막 항목 ~ 화면 하단 여백

  /// 로그아웃: 확인 모달 > (확인 시) 로그아웃
  Future<void> _onLogoutTap(BuildContext context) async {
    final bool confirmed = await showLogoutModal(context);
    if (!confirmed || !context.mounted) return; // 돌아가기: 모달만 닫힘

    // TODO: 로그아웃 API 연동 + 토큰 삭제 + 로그인 화면으로 이동
  }

  /// 회원탈퇴: 경고 모달 > (확인 시) 탈퇴 (계정 데이터 전부 삭제)
  Future<void> _onDeleteAccountTap(BuildContext context) async {
    final bool confirmed = await showDeleteAccountModal(context);
    if (!confirmed || !context.mounted) return; // 돌아가기: 모달만 닫힘

    // TODO: 회원탈퇴 API 연동 + 로컬 데이터 삭제 + 로그인 화면으로 이동
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MyProfile> asyncProfile = ref.watch(myProfileProvider);
    final bool isPushEnabled = ref.watch(pushNotificationProvider);

    return AppPage(
      backgroundColor: AppColors.bgSolidBasic,
      isScrollable: true,
      header: const TitleHeader(title: '마이페이지'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: _profileTopGap),

          // 프로필 (이름 + 이메일)
          asyncProfile.when(
            loading: () => const ShowGlobalLoading(),
            error: (_, _) => Text(
              '프로필을 불러오지 못했어요.',
              style: AppTextStyles.bodyMedium16.copyWith(color: AppColors.gray400),
            ),
            data: (profile) => ProfileSection(
              name: profile.name,
              email: profile.email,
              onNameSubmitted: ref.read(myProfileProvider.notifier).updateName,
            ),
          ),
          const SizedBox(height: _settingsTopGap),

          // 앱 설정 (푸시 알림 / 로그아웃 / 회원탈퇴)
          AppSettingsSection(
            isPushEnabled: isPushEnabled,
            onPushChanged: ref.read(pushNotificationProvider.notifier).setEnabled,
            onLogoutTap: () => _onLogoutTap(context),
            onDeleteAccountTap: () => _onDeleteAccountTap(context),
          ),
          const SizedBox(height: _contentBottomGap),
        ],
      ),
    );
  }
}