// 코스 정보 추출 페이지

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/core/theme/app_colors.dart';
import 'package:plan_b/core/theme/app_text_styles.dart';
import 'package:plan_b/features/course/data/models/extracted_course.dart';
import 'package:plan_b/features/course/presentation/providers/extracted_course_provider.dart';
import 'package:plan_b/features/course/presentation/providers/my_course_provider.dart';
import 'package:plan_b/features/course/presentation/widgets/extracted_course_list.dart';
import 'package:plan_b/shared/providers/selected_plan_id_provider.dart';
import 'package:plan_b/shared/widgets/background/bg_bottom_ellipse.dart';
import 'package:plan_b/shared/widgets/background/bg_top_ellipse.dart';
import 'package:plan_b/shared/widgets/feedback/global_loading/show_global_loading.dart';
import 'package:plan_b/shared/widgets/feedback/toast.dart';
import 'package:plan_b/shared/widgets/header/title_header.dart';
import 'package:plan_b/shared/widgets/nav/top_app_bar.dart';

class DataExtractionPage extends ConsumerStatefulWidget {
  const DataExtractionPage({super.key, required this.links});

  final List<String> links; // 코스 추가 화면에서 입력한 링크

  @override
  ConsumerState<DataExtractionPage> createState() => _DataExtractionPageState();
}

class _DataExtractionPageState extends ConsumerState<DataExtractionPage> {
  static const double _listTopGap = 32;       // 헤더 ~ 첫 카드 간격
  static const double _contentBottomGap = 24; // 마지막 카드 ~ 로컬 탭바 간격

  final Set<String> _addingIds = {}; // 추가 요청 중인 코스
  final Set<String> _addedIds = {};  // 이미 추가한 코스

  /// '+' 버튼: 내 플랜에 코스 추가 요청 > 버튼 상태, 토스트 처리
  /// (요청과 나의 여행 코스 갱신은 MyCourseNotifier가 처리: 화면을 닫아도 반영됨)
  Future<void> _addCourse(ExtractedCourse course) async {
    final String? planId = ref.read(selectedPlanIdProvider);
    if (planId == null) return;

    // await 전에 notifier를 잡아둠 (화면이 닫힌 뒤에는 ref를 쓸 수 없음)
    final MyCourseNotifier notifier =
        ref.read(myCourseProvider(planId).notifier);

    setState(() => _addingIds.add(course.id));
    try {
      await notifier.addExtractedCourse(course);
      if (!mounted) return; // 화면이 닫혔으면 토스트, 버튼 상태만 생략 (반영은 이미 완료)

      setState(() => _addedIds.add(course.id));
      showToast(context, text: '코스를 내 플랜에 추가했어요');
    } catch (_) {
      if (!mounted) return;
      showToast(
        context,
        text: '코스를 추가하지 못했어요.\n다시 시도해주세요',
        type: ToastType.warning,
      );
    } finally {
      if (mounted) setState(() => _addingIds.remove(course.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ExtractedCourse>> asyncCourses = ref.watch(
      extractedCoursesProvider(extractedCoursesKeyOf(widget.links)),
    );

    return Scaffold(
      backgroundColor: AppColors.blue50,
      extendBodyBehindAppBar: true, // 배경 ellipse가 상단바 뒤까지 깔리도록
      appBar: const TopAppBar(), // 뒤로가기 > 코스 추가 화면 (입력한 링크 유지)
      body: Builder(
        builder: (context) {
          // top: 상태바 + 상단바 / bottom: 로컬 탭바 + 홈 인디케이터 (LocalShell extendBody)
          final EdgeInsets inset = MediaQuery.paddingOf(context);

          return Stack(
            fit: StackFit.expand,
            children: [
              const BgTopEllipse(),
              const BgBottomEllipse(),
              Positioned(
                top: inset.top,
                left: 0,
                right: 0,
                bottom: 0,
                child: asyncCourses.when(
                  loading: () => const ShowGlobalLoading(),
                  error: (_, _) => const _ExtractionMessage(
                    text: '코스를 추출하지 못했어요.\n잠시 후 다시 시도해주세요.',
                  ),
                  data: (courses) => courses.isEmpty
                      ? const _ExtractionMessage(
                          text: '링크에서 추가할 수 있는 코스를 찾지 못했어요.',
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 헤더는 고정, 카드 목록만 스크롤 (헤더 경계에서 잘림)
                            const TitleHeader(
                              title: '예산에 맞는 코스 추출 완료!',
                              subtitle: '각 코스를 확인하고, 마음에 드는 코스는\n'
                                  '내 여행 플랜에 추가해 보세요.',
                              size: TitleHeaderSize.md,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                clipBehavior: Clip.hardEdge,
                                padding: EdgeInsets.fromLTRB(
                                  24,
                                  _listTopGap,
                                  24,
                                  inset.bottom + _contentBottomGap,
                                ),
                                child: ExtractedCourseList(
                                  courses: courses,
                                  disabledIds: {..._addingIds, ..._addedIds},
                                  onAddPressed: _addCourse,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 추출 실패 / 추출된 코스 없음 안내 문구
class _ExtractionMessage extends StatelessWidget {
  const _ExtractionMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium16.copyWith(color: AppColors.gray400),
      ),
    );
  }
}