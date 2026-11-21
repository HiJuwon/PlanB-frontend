// 웹에서 찾은 코스 추가하기 페이지

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:plan_b/core/config/app_routes.dart';
import 'package:plan_b/core/theme/app_colors.dart';
import 'package:plan_b/features/course/presentation/widgets/add_the_course/link_guide_box.dart';
import 'package:plan_b/features/course/presentation/widgets/add_the_course/link_input_section.dart';
import 'package:plan_b/shared/widgets/app_page.dart';
import 'package:plan_b/shared/widgets/btn/cta.dart';
import 'package:plan_b/shared/widgets/feedback/toast.dart';
import 'package:plan_b/shared/widgets/header/title_header.dart';
import 'package:plan_b/shared/widgets/nav/top_app_bar.dart';

class AddTheCoursePage extends StatelessWidget {
  const AddTheCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldMessenger(child: _AddTheCourseView());
  }
}

class _AddTheCourseView extends StatefulWidget {
  const _AddTheCourseView();

  @override
  State<_AddTheCourseView> createState() => _AddTheCourseViewState();
}

class _AddTheCourseViewState extends State<_AddTheCourseView> {
  static const int _maxLinkCount = 5;         // 한 번에 입력 가능한 최대 링크 수
  static const double _sectionTopGap = 20;    // 헤더 ~ 링크 입력 영역
  static const double _dividerGap = 36;       // 링크 영역 ~ 구분선 ~ 안내 박스
  static const double _contentBottomGap = 24; // 안내 박스 ~ 스크롤 끝
  static const double _ctaBottomGap = 16;     // CTA ~ 로컬 탭바
  static const double _ctaHorizontalPadding = 24; // AppPage 좌우 패딩을 0으로 둬서 CTA에 직접 적용하는 여백값

  final List<TextEditingController> _controllers = [TextEditingController()];
  TextEditingController? _autofocusTarget; // '링크 추가'로 새로 연 필드에만 focus

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 입력된 링크 (빈 필드는 제외, 앞뒤 공백 제거)
  List<String> get _links => [
        for (final controller in _controllers)
          if (controller.text.trim().isNotEmpty) controller.text.trim(),
      ];

  bool get _canSubmit => _links.isNotEmpty;

  /// '링크 추가': 최대 개수면 토스트, 아니면 입력 필드 하나 더 열기
  void _addLinkField() {
    if (_controllers.length >= _maxLinkCount) {
      showToast(
        context,
        text: '링크는 최대 $_maxLinkCount개까지\n입력할 수 있어요',
        type: ToastType.alert,
      );
      return;
    }

    final TextEditingController controller = TextEditingController();
    setState(() {
      _controllers.add(controller);
      _autofocusTarget = controller;
    });
  }

  /// '붙여넣기 완료': 링크 형식 / 중복 확인 후 코스 정보 추출 화면으로 보낸다
  void _submit() {
    FocusScope.of(context).unfocus();
    final List<String> links = _links;

    if (links.any((link) => !_isHttpUrl(link))) {
      showToast(
        context,
        text: '링크는 https:// 또는\nhttp://로 시작해야 해요',
        type: ToastType.warning,
      );
      return;
    }

    if (links.toSet().length != links.length) {
      showToast(
        context,
        text: '같은 링크가 이미 입력되어 있어요',
        type: ToastType.warning,
      );
      return;
    }

    context.go(AppRoutes.courseExtraction, extra: links);
  }

  static bool _isHttpUrl(String value) {
    final Uri? uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const TopAppBar(), // 뒤로가기 누르면: 여행 코스 페이지로 나감
      isScrollable: true,
      horizontalPadding: 0, // 구분선이 화면 끝까지 닿도록
      header: const TitleHeader(
        title: '여행에 담고 싶은 링크를\n붙여넣어 보세요',
        subtitle: 'AI가 링크 속 여행 정보를 분석해,\n예산에 맞는 코스만 골라드려요.',
        size: TitleHeaderSize.md,
      ),
      bottomCta: Padding(
        padding: const EdgeInsets.fromLTRB(
          _ctaHorizontalPadding,
          0,
          _ctaHorizontalPadding,
          _ctaBottomGap,
        ),
        child: Cta(
          text: '붙여넣기 완료',
          isActive: _canSubmit, // 링크를 1개 이상 입력해야 활성화됨.
          onPressed: _submit,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: _sectionTopGap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LinkInputSection(
              controllers: _controllers,
              autofocusTarget: _autofocusTarget,
              onChanged: (_) => setState(() {}), // CTA 활성화 갱신
              onAddPressed: _addLinkField,
            ),
          ),
          const SizedBox(height: _dividerGap),
          const ColoredBox(
            color: AppColors.gray50,
            child: SizedBox(height: 1, width: double.infinity),
          ),
          const SizedBox(height: _dividerGap),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: LinkGuideBox(),
          ),
          const SizedBox(height: _contentBottomGap),
        ],
      ),
    );
  }
}