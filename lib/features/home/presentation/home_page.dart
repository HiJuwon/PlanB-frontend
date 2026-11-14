// 홈 화면

import 'package:flutter/material.dart';

import 'package:plan_b/core/theme/app_colors.dart';
import 'package:plan_b/core/theme/app_text_styles.dart';
import 'package:plan_b/features/home/data/dummy/trip_plan_summary_dummy.dart';
import 'package:plan_b/features/home/data/models/trip_plan_summary.dart';
import 'package:plan_b/features/home/data/models/trip_time_status.dart';
import 'package:plan_b/features/home/presentation/widgets/main_app_bar.dart';
import 'package:plan_b/features/home/presentation/widgets/main_segmented_control/main_segmented_control.dart';
import 'package:plan_b/features/home/presentation/widgets/ongoing_trip_card/ongoing_trip_carousel.dart';
import 'package:plan_b/features/home/presentation/widgets/trip_plan_list/trip_plan_list.dart';
import 'package:plan_b/shared/widgets/background/bg_bottom_ellipse.dart';
import 'package:plan_b/shared/widgets/header/title_header.dart';
import 'package:plan_b/shared/widgets/date_change_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // TODO: 로그인 연동 후 사용자 이름으로 교체
  static const String _userName = '주원';

  // TODO: API 연동 후 서버 데이터로 교체
  final List<TripPlanSummary> _plans = buildDummyTripPlans();

  MainSegment _segment = MainSegment.upcomingTrip;

  /// 상태별 플랜 목록 (정렬 규칙 적용)
  List<TripPlanSummary> _plansOf(TripTimeStatus status) {
    // 시작일이 같을 때 생성순을 유지하기 위해 원래 순서(index)를 함께 들고 정렬
    final indexed = [
      for (final (index, plan) in _plans.indexed)
        if (plan.status == status) (index, plan),
    ];

    indexed.sort((a, b) {
      final byDate = status == TripTimeStatus.past
          ? b.$2.period.start.compareTo(a.$2.period.start) // 지난 여행: 최근 순
          : a.$2.period.start.compareTo(b.$2.period.start); // 다가오는 여행: 가까운 순
      return byDate != 0 ? byDate : a.$1.compareTo(b.$1); // 같은 날짜면 생성순
    });

    return [for (final (_, plan) in indexed) plan];
  }

  @override
  Widget build(BuildContext context) {
    // 날짜가 바뀌면 플랜 상태(다가오는 / 진행중 / 지난)와 디데이를 다시 계산
    return DateChangeBuilder(
      builder: (context, today) {
        final hasOngoing =
            _plans.any((plan) => plan.status == TripTimeStatus.ongoing);

        final listedPlans = _plansOf(
          _segment == MainSegment.upcomingTrip
              ? TripTimeStatus.upcoming
              : TripTimeStatus.past,
        );

    return Scaffold(
      backgroundColor: AppColors.bgSolidBasic,
      extendBodyBehindAppBar: true, // 배경 그래픽이 상단바 뒤까지 깔리도록
      appBar: MainAppBar(
        onNotificationTap: () {},
      ),
      body: Builder(
        builder: (context) {
          // 상태바 + 상단바 높이
          // (Scaffold body 안의 context에서 읽어야 extendBodyBehindAppBar로 합쳐진 상단바 높이가 포함됨)
          final topInset = MediaQuery.paddingOf(context).top;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 배경 1: 상단 구름 그래픽 (화면 제일 밑에 배치)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/img/img_bg_top_graphic_home.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),

              // 배경 2: 하단 ellipse
              const BgBottomEllipse(),

              // 콘텐츠: 상단바 아래에서 시작, 스크롤하면 상단바 경계에서 잘림
              Positioned(
                top: topInset,
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomScrollView(
                  clipBehavior: Clip.hardEdge, // 상단바 경계에서 콘텐츠를 자름 (기본값이지만 의도를 명시)
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16), // 상단바 ~ 헤더 간격

                          const TitleHeader(
                            title: '반가워요, $_userName 님!',
                            subtitle: '즐거운 여행 준비가 되길 바랄게요.',
                            align: TitleHeaderAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // 진행중인 여행 (있을 때만): 캐러셀이 좌우 여백을 직접 가지므로 전체 너비로 배치
                          if (hasOngoing) ...[
                            OngoingTripCarousel(plans: _plans),
                            const SizedBox(height: 60),
                          ],

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: MainSegmentedControl(
                              selected: _segment,
                              onSelected: (segment) =>
                                  setState(() => _segment = segment),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    // 여행 플랜 카드 목록 / 빈 목록 안내
                    if (listedPlans.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false, // 남은 영역을 채우고 그 가운데에 문구 표시
                        child: Center(
                          child: Text(
                            '여행 플랜이 없어요',
                            style: AppTextStyles.bodyMedium16.copyWith(
                              color: AppColors.gray400,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40), // 좌우 24, 하단 여백 40
                        sliver: SliverToBoxAdapter(
                          child: TripPlanList(plans: listedPlans),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  );
  }
}