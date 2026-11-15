// 월별 여행 준비 가이드 페이지
// - 홈에서 선택한 플랜 id(selectedPlanIdProvider)의 월별 가이드를 조회해서 보여주어야 함.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:plan_b/core/config/app_routes.dart';
import 'package:plan_b/core/theme/app_colors.dart';
import 'package:plan_b/core/theme/app_text_styles.dart';
import 'package:plan_b/features/monthly_guide/data/models/guide_view_type.dart';
import 'package:plan_b/features/monthly_guide/data/models/monthly_guide.dart';
import 'package:plan_b/features/monthly_guide/presentation/providers/monthly_guide_provider.dart';
import 'package:plan_b/features/monthly_guide/presentation/widgets/btn_swap_guide_view.dart';
import 'package:plan_b/features/monthly_guide/presentation/widgets/monthly_month_view.dart';
import 'package:plan_b/shared/providers/selected_plan_id_provider.dart';
import 'package:plan_b/shared/widgets/background/bg_bottom_ellipse.dart';
import 'package:plan_b/shared/widgets/background/bg_top_ellipse.dart';
import 'package:plan_b/shared/widgets/feedback/global_loading/show_global_loading.dart';
import 'package:plan_b/shared/widgets/nav/top_app_bar.dart';

class MonthlyGuidePage extends ConsumerStatefulWidget {
  const MonthlyGuidePage({super.key});

  @override
  ConsumerState<MonthlyGuidePage> createState() => _MonthlyGuidePageState();
}

class _MonthlyGuidePageState extends ConsumerState<MonthlyGuidePage> {
  static const double _contentTopGap = 24;    // 상단바 ~ 요약 박스 간격
  static const double _contentBottomGap = 24; // 마지막 콘텐츠 ~ 로컬 탭바 간격
  static const double _swapButtonGap = 16;    // 보기 전환 버튼 ~ 로컬 탭바 간격
  static const double _horizontalPadding = 24;

  GuideViewType _viewType = GuideViewType.monthlyGuide; // 현재 보기

  void _toggleView() => setState(() => _viewType = _viewType.toggled);

  @override
  Widget build(BuildContext context) {
    // 선택을 해제한 직후 화면을 벗어나기 전 한 번 더 그려질 수 있어 null 처리 (플래너와 동일)
    final String? planId = ref.watch(selectedPlanIdProvider);

    return Scaffold(
      backgroundColor: AppColors.blue50,
      extendBodyBehindAppBar: true, // 배경 ellipse가 상단바 뒤까지 깔리도록
      appBar: TopAppBar(
        title: '월별 여행 준비 가이드',
        // local shell 탭의 첫 화면이라 기본 pop으로 나가지 못하므로 홈으로 직접 이동
        onBack: () => context.go(AppRoutes.home),
      ),
      body: Builder(
        builder: (context) {
          // top: 상태바 + 상단바 / bottom: 로컬 탭바 + 홈 인디케이터 (LocalShell extendBody)
          final EdgeInsets inset = MediaQuery.paddingOf(context);

          return Stack(
            fit: StackFit.expand,
            children: [
              const BgTopEllipse(),
              const BgBottomEllipse(),

              // 콘텐츠: 상단바 아래에서 시작, 스크롤하면 상단바 경계에서 잘림 / 로컬 탭바 뒤로는 지나감
              Positioned(
                top: inset.top,
                left: 0,
                right: 0,
                bottom: 0,
                child: SingleChildScrollView(
                  clipBehavior: Clip.hardEdge,
                  padding: EdgeInsets.fromLTRB(
                    _horizontalPadding,
                    _contentTopGap,
                    _horizontalPadding,
                    inset.bottom + _contentBottomGap,
                  ),
                  child: planId == null
                      ? const SizedBox.shrink()
                      : _buildContent(planId),
                ),
              ),

              // 보기 전환 버튼: 로컬 탭바 위에 떠 있음 (버튼 문구 = 누르면 바뀔 보기)
              Positioned(
                right: _horizontalPadding,
                bottom: inset.bottom + _swapButtonGap,
                child: BtnSwapGuideView(
                  viewType: _viewType.toggled,
                  onTap: _toggleView,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(String planId) {
    return switch (_viewType) {
      GuideViewType.monthlyGuide => _MonthlyGuideContent(planId: planId),
      GuideViewType.timeline => const _TimelinePlaceholder(),
    };
  }
}

/// 월별 가이드 데이터 조회 + 월별 보기
class _MonthlyGuideContent extends ConsumerWidget {
  const _MonthlyGuideContent({required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MonthlyGuide> asyncGuide =
        ref.watch(monthlyGuideProvider(planId));

    return asyncGuide.when(
      loading: () => const ShowGlobalLoading(),
      error: (_, _) => const _MessageText('월별 여행 준비 가이드를 불러오지 못했어요.'),
      data: (guide) => MonthlyMonthView(
        guide: guide,
        onTodoToggled: (todoId) =>
            ref.read(monthlyGuideProvider(planId).notifier).toggleTodo(todoId),
      ),
    );
  }
}

/// 전체 타임라인 보기 자리 (임시)
class _TimelinePlaceholder extends StatelessWidget {
  const _TimelinePlaceholder();

  @override
  Widget build(BuildContext context) =>
      const _MessageText('전체 타임라인');
}

/// 오류 및 임시 안내 문구 (플래너 및 코스 페이지와 같은 스타일)
class _MessageText extends StatelessWidget {
  const _MessageText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium16.copyWith(color: AppColors.gray400),
      ),
    );
  }
}