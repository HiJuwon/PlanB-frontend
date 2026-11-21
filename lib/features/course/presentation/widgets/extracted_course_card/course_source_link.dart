// 추출된 코스 카드) '원본 출처' 텍스트 링크
// 누르면 외부 브라우저로 원본 페이지 열리도록

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:plan_b/core/theme/app_colors.dart';
import 'package:plan_b/core/theme/app_text_styles.dart';
import 'package:plan_b/shared/widgets/feedback/toast.dart';

class CourseSourceLink extends StatelessWidget {
  const CourseSourceLink({super.key, required this.url});

  final String url; // 원본 출처 링크

  static const double _iconSize = 16;

  Future<void> _open(BuildContext context) async {
    final Uri? uri = Uri.tryParse(url);
    bool opened = false;

    if (uri != null && uri.hasScheme) {
      try {
        // 인앱브라우저로 열리도록
        opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {
        opened = false;
      }
    }

    if (!opened && context.mounted) {
      showToast(
        context,
        text: '원본 페이지를 열지 못했어요.',
        type: ToastType.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      label: '원본 출처 열기',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _open(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            Text(
              '원본 출처',
              style: AppTextStyles.bodyMedium14.copyWith(
                color: AppColors.gray600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.gray600,
              ),
            ),
            SvgPicture.asset(
              'assets/icons/ic_arrow_link_16px.svg',
              width: _iconSize,
              height: _iconSize,
            ),
          ],
        ),
      ),
    );
  }
}