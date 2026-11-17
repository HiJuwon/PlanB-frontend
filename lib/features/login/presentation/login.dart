import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:plan_b/core/theme/app_colors.dart';
import 'package:plan_b/core/theme/app_text_styles.dart';
import 'package:plan_b/features/login/presentation/widgets/cta_social_login.dart';
import 'package:plan_b/shared/widgets/background/bg_bottom_ellipse.dart';
import 'package:plan_b/shared/widgets/background/bg_top_gradient.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const double _logoWidth = 155;
  static const double _logoHeight = 60;
  static const double _logoToIntroGap = 33;   // 로고 ~ 소개 문구 간격
  static const double _introToCtaGap = 163;   // 소개 문구 ~ 로그인 버튼 간격
  static const double _ctaGap = 16;           // 로그인 버튼 사이 간격

  static const String _intro = '여행의 복잡한 과정은 줄여주는,\n'
      '당신만을 위한 여행 준비 파트너';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSolidBasic,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 배경: 하단 ellipse + 상단 gradient
          const BgBottomEllipse(),
          const BgTopGradient(),

          // 콘텐츠: 피그마상 화면 전체(상태바 포함) 기준 세로 중앙 정렬
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 로고 + 소개 문구
                  SvgPicture.asset(
                    'assets/logos/logo_planb_lg.svg',
                    width: _logoWidth,
                    height: _logoHeight,
                  ),
                  const SizedBox(height: _logoToIntroGap),
                  Text(
                    _intro,
                    style: AppTextStyles.titleMedium18
                        .copyWith(color: AppColors.gray500),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: _introToCtaGap),

                  // 소셜 로그인 버튼
                  Column(
                    spacing: _ctaGap,
                    children: [
                      CtaSocialLogin(
                        type: SocialLoginType.kakao,
                        onPressed: () {}, // TODO: 카카오 로그인 연동
                      ),
                      CtaSocialLogin(
                        type: SocialLoginType.google,
                        onPressed: () {}, // TODO: 구글 로그인 연동
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}