// 나의 여행 플래너 페이지
// - 홈에서 선택한 플랜 id(selectedPlanIdProvider)의 여행 플랜 기본 데이터를 조회해서 보여준다

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:plan_b/core/config/app_routes.dart';
import 'package:plan_b/core/theme/app_colors.dart';
import 'package:plan_b/core/theme/app_text_styles.dart';
import 'package:plan_b/shared/providers/global_loading_provider.dart';
import 'package:plan_b/shared/widgets/feedback/global_loading/show_global_loading.dart';
import 'package:plan_b/features/planner/data/dummy/planner_trip_check_dummy.dart';
import 'package:plan_b/features/planner/data/models/planner_trip_plan.dart';
import 'package:plan_b/features/planner/presentation/providers/planner_trip_plan_provider.dart';
import 'package:plan_b/features/planner/presentation/widgets/my_trip_planner/my_trip_planner.dart';
import 'package:plan_b/features/trip_check/data/models/trip_check_draft.dart';
import 'package:plan_b/features/trip_check/presentation/providers/trip_check_draft_provider.dart';
import 'package:plan_b/shared/providers/selected_plan_id_provider.dart';
import 'package:plan_b/shared/widgets/background/bg_bottom_ellipse.dart';
import 'package:plan_b/shared/widgets/background/bg_top_ellipse.dart';
import 'package:plan_b/shared/widgets/btn/btn_text_secondary.dart';
import 'package:plan_b/shared/widgets/feedback/modal_primary.dart';
import 'package:plan_b/shared/widgets/nav/top_app_bar.dart';

class PlannerPage extends ConsumerWidget {
  const PlannerPage({super.key});

  static const double _contentTopGap = 24;    // 상단바 ~ 플래너 간격
  static const double _contentBottomGap = 24; // 마지막 콘텐츠 ~ 로컬 탭바 간격

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // router redirect가 null이면 홈으로 보내지만,
    // '다시 선택하기'에서 선택을 해제한 직후 화면을 벗어나기 전 한 번 더 그려질 수 있어 null 처리
    final String? planId = ref.watch(selectedPlanIdProvider);

    return Scaffold(
      backgroundColor: AppColors.blue50,
      extendBodyBehindAppBar: true, // 배경 ellipse가 상단바 뒤까지 깔리도록
      appBar: TopAppBar(
        title: '나의 여행 플래너',
        // 플래너는 local shell 탭의 첫 화면이라 기본 pop으로 나가지 못하기 때문에, 홈으로 직접 이동하게 처리.
        onBack: () => context.go(AppRoutes.home),
      ),
      body: Builder(
        builder: (context) {
          // top: 상태바 + 상단바 / bottom: 로컬 탭바 + 홈 인디케이터 (LocalShell extendBody)
          // (Scaffold body 안의 context에서 읽어야 합쳐진 높이가 들어옴)
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
                    24,
                    _contentTopGap,
                    24,
                    inset.bottom + _contentBottomGap,
                  ),
                  child: planId == null
                      ? const SizedBox.shrink()
                      : _PlannerContent(planId: planId),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 플랜 데이터 조회 + 플래너 / 다시 선택하기 버튼
class _PlannerContent extends ConsumerWidget {
  const _PlannerContent({required this.planId});

  final String planId;

  /// 다시 선택하기: 확인 모달 > 플랜 초기화 > 여행 고르기로
  Future<void> _onReselectPressed(
    BuildContext context,
    WidgetRef ref,
    PlannerTripPlan plan,
  ) async {
    final bool confirmed = await showModalPrimary(
      context,
      title: '나의 여행 플랜을\n다시 선택하시겠습니까?',
      caption: '현재 진행 중인 플랜은 초기화됩니다.',
      secondaryText: '취소',
      primaryText: '확인',
    );
    if (!confirmed || !context.mounted) return; // 취소: 모달만 닫힘

    final TripCheckDraft draft = await ref
      .read(globalLoadingProvider.notifier)
      .run(() => _requestPlanReselect(plan));
    if (!context.mounted) return;

    // 여행 고르기가 이 플랜을 만들 때의 조건(플로우, 기본 정보)으로 보이도록 입력 상태 복원
    ref.read(tripCheckDraftProvider.notifier).restore(draft);
    // 초기화된 플랜이므로 선택 해제 (플랜 화면에 다시 들어오면 홈으로 redirect)
    ref.read(selectedPlanIdProvider.notifier).clear();
    // 홈, 플래너 스택을 비우고 여행 고르기로
    // (여행 고르기의 뒤로가기/돌아가기는 기존처럼 '여행 조건 다시 선택' 모달로 처리됨)
    context.go(AppRoutes.tripSelect);
  }

  /// 플랜 초기화 요청 -> 플랜 생성 당시의 맞춤 여행 체크 조건 응답
  // TODO: 서버 API 연동 (planId 전송 -> 플랜 초기화 + 맞춤 여행 체크 조건 & 추천 플랜 3개 응답)
  Future<TripCheckDraft> _requestPlanReselect(PlannerTripPlan plan) async {
    await Future<void>.delayed(const Duration(milliseconds: 300)); // 임시: 서버 응답 대기 흉내
    return dummyTripCheckDraftOf(plan);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PlannerTripPlan> asyncPlan =
        ref.watch(plannerTripPlanProvider(planId));

    return asyncPlan.when(
      loading: () => const ShowGlobalLoading(),
      error: (_, _) => Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          '여행 플랜을 불러오지 못했어요.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium16.copyWith(color: AppColors.gray400),
        ),
      ),
      data: (plan) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20, // 플래너 ~ 다시 선택하기 버튼 사이 간격
        children: [
          MyTripPlanner(plan: plan),
          Center(
            child: BtnTextSecondary(
              text: '여행 플랜 다시 선택하기',
              onPressed: () => _onReselectPressed(context, ref, plan),
            ),
          ),
        ],
      ),
    );
  }
}