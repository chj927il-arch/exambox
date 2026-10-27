import 'package:flutter/material.dart';
import '../data/board_data.dart';
import '../data/lecture_data.dart';
import '../data/user_reviews.dart';
import '../models/exam_subject.dart';
import '../theme/app_theme.dart';
import '../theme/ott_theme.dart';
import '../theme/subject_style.dart';
import '../widgets/hscroll_list.dart';
import '../widgets/like_badge.dart';
import '../widgets/marquee_row.dart';
import 'full_mock_exam_screen.dart';
import 'lecture_grid_screen.dart';
import 'lecture_intro_screen.dart';
import 'quiz_screen.dart';
import 'review_screen.dart';
import 'subject_grid_screen.dart';
import 'subject_info_screen.dart';
import 'time_attack_screen.dart';

const double kLecturePosterWidth = 152;
const double kLecturePosterHeight = 216;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final TabController _lectureTab;

  @override
  void initState() {
    super.initState();
    _lectureTab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _lectureTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    return ColoredBox(
      color: OttColors.bg,
      child: ScrollbarTheme(
        data: const ScrollbarThemeData(
          thumbColor: WidgetStatePropertyAll(Color(0xFF3A4055)),
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          interactive: true,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 0, bottom: 56),
            children: [
              _DashboardHeader(isDesktop: isDesktop),
              const SizedBox(height: 32),

              // 과목별 학습
              _SectionTitle(
                icon: Icons.menu_book_outlined,
                title: '과목별 학습',
                subtitle: '가맹거래사 1차 3과목',
                onMore: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SubjectGridScreen()),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SubjectCardGrid(isDesktop: isDesktop),
              ),
              const SizedBox(height: 32),

              // 실전 연습
              const _SectionTitle(
                icon: Icons.flash_on_outlined,
                title: '실전 연습',
                subtitle: '시험 직전 점검',
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _PracticeGrid(isDesktop: isDesktop),
              ),
              const SizedBox(height: 32),

              // 단원별 강의
              const _SectionTitle(
                icon: Icons.play_lesson_outlined,
                title: '단원별 강의',
                subtitle: '챕터별 핵심 특강',
              ),
              const SizedBox(height: 12),
              _LectureTabs(controller: _lectureTab),
              const SizedBox(height: 32),

              // 수강후기
              const _SectionTitle(
                icon: Icons.star_outline_rounded,
                title: '수강후기',
              ),
              const SizedBox(height: 14),
              const _ReviewCarousel(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 상단 대시보드 헤더 ──────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final bool isDesktop;
  const _DashboardHeader({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.year}년 ${now.month}월 ${now.day}일';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 40 : 20,
        isDesktop ? 36 : 28,
        isDesktop ? 40 : 20,
        isDesktop ? 36 : 28,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: OttColors.border)),
      ),
      child: isDesktop
          ? Row(
              children: [
                _HeaderText(dateStr: dateStr),
                const Spacer(),
                _ExamBadge(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderText(dateStr: dateStr),
                const SizedBox(height: 12),
                _ExamBadge(),
              ],
            ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String dateStr;
  const _HeaderText({required this.dateStr});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dateStr,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: OttColors.textMuted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '스터디박스',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '가맹거래사 1차 시험 · 민법 · 경제법 · 경영학',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: OttColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ExamBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: OttColors.accentStart.withValues(alpha: 0.14),
        border: Border.all(color: OttColors.accentStart.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_outlined, color: OttColors.accentStart, size: 16),
          SizedBox(width: 7),
          Text(
            '가맹거래사 1차',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: OttColors.accentStart,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 섹션 타이틀 ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onMore;
  const _SectionTitle({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: OttColors.accentStart.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: OttColors.accentStart, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: OttColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (onMore != null)
            InkWell(
              onTap: onMore,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '더보기',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: OttColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 16, color: OttColors.textMuted),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 과목 카드 그리드 ─────────────────────────────────────────────────────────

class _SubjectCardGrid extends StatelessWidget {
  final bool isDesktop;
  const _SubjectCardGrid({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: examSubjects
            .map((s) => Expanded(child: Padding(
                  padding: EdgeInsets.only(
                    right: s == examSubjects.last ? 0 : 14,
                  ),
                  child: _SubjectDashCard(subject: s),
                )))
            .toList(),
      );
    }
    return Column(
      children: examSubjects
          .map((s) => Padding(
                padding: EdgeInsets.only(bottom: s == examSubjects.last ? 0 : 12),
                child: _SubjectDashCard(subject: s),
              ))
          .toList(),
    );
  }
}

class _SubjectDashCard extends StatelessWidget {
  final ExamSubject subject;
  const _SubjectDashCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final style = subjectStyleOf(subject.id);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SubjectInfoScreen(
            subjectId: subject.id,
            subjectName: subject.name,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: OttColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border(
            left: BorderSide(color: style.color, width: 3),
            top: BorderSide(color: OttColors.border),
            right: BorderSide(color: OttColors.border),
            bottom: BorderSide(color: OttColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SubjectInfoScreen(
                  subjectId: subject.id,
                  subjectName: subject.name,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: style.color.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(style.icon, color: style.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        subject.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: subject.categories
                        .map((c) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: style.color.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: style.color.withValues(alpha: 0.25)),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: style.color,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        '챕터별 학습하기',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: style.color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: style.color),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 실전 연습 그리드 ─────────────────────────────────────────────────────────

class _PracticeGrid extends StatelessWidget {
  final bool isDesktop;
  const _PracticeGrid({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final items = [
      _PracticeItem(
        icon: Icons.assignment_outlined,
        label: '실전모의고사',
        desc: '전범위 70문항',
        color: const Color(0xFF3B5BFF),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FullMockExamScreen()),
        ),
      ),
      _PracticeItem(
        icon: Icons.timer_outlined,
        label: '타임어택',
        desc: '1분 제한 스피드 풀기',
        color: const Color(0xFFE0A93B),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TimeAttackScreen()),
        ),
      ),
      _PracticeItem(
        icon: Icons.warning_amber_outlined,
        label: '틀리기 쉬운 문제',
        desc: '함정 유형 집중 풀이',
        color: const Color(0xFFE05050),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const QuizScreen(
              subjectId: 'trap_quiz_season1',
              subjectName: '틀리기 쉬운 문제 시즌1',
              category: '함정 피하기',
              crossSubjectIds: ['economic_law', 'civil_law', 'business_admin'],
            ),
          ),
        ),
      ),
    ];

    if (isDesktop) {
      return Row(
        children: items
            .map((item) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: item == items.last ? 0 : 14),
                    child: _PracticeCard(item: item),
                  ),
                ))
            .toList(),
      );
    }

    return Column(
      children: items
          .map((item) => Padding(
                padding: EdgeInsets.only(bottom: item == items.last ? 0 : 10),
                child: _PracticeCard(item: item),
              ))
          .toList(),
    );
  }
}

class _PracticeItem {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final VoidCallback onTap;
  const _PracticeItem({
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
    required this.onTap,
  });
}

class _PracticeCard extends StatelessWidget {
  final _PracticeItem item;
  const _PracticeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OttColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OttColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.desc,
                        style: const TextStyle(
                          fontSize: 12,
                          color: OttColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: OttColors.textMuted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 강의 탭 섹션 ─────────────────────────────────────────────────────────────

class _LectureTabs extends StatelessWidget {
  final TabController controller;
  const _LectureTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: OttColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: OttColors.border),
            ),
            child: TabBar(
              controller: controller,
              indicator: BoxDecoration(
                color: OttColors.accentStart.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: OttColors.accentStart.withValues(alpha: 0.40)),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: OttColors.textMuted,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: '민법'),
                Tab(text: '경제법'),
                Tab(text: '경영학'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: kLecturePosterHeight,
          child: TabBarView(
            controller: controller,
            children: [
              _LectureRow(lectures: civilLawLectures, subjectId: 'civil_law'),
              _LectureRow(lectures: economicLawLectures, subjectId: 'economic_law'),
              _LectureRow(lectures: businessAdminLectures, subjectId: 'business_admin'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LectureGridScreen()),
              ),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '전체 강의 보기',
                      style: TextStyle(fontSize: 12.5, color: OttColors.textMuted, fontWeight: FontWeight.w700),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 16, color: OttColors.textMuted),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LectureRow extends StatelessWidget {
  final List<LectureItem> lectures;
  final String subjectId;
  const _LectureRow({required this.lectures, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return HScrollList(
      height: kLecturePosterHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: lectures.length,
      itemBuilder: (context, index) {
        final item = lectures[index];
        final onTap = (BuildContext ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) => LectureIntroScreen(
              title: item.title,
              keyPoints: item.keyPoints,
              subjectId: item.subjectId,
              subjectName: item.subjectName,
              category: item.category,
              subTopic: item.subTopic,
            ),
          ),
        );
        if (item.imageAsset != null) {
          return LectureCoverCard(
            imageAsset: item.imageAsset!,
            likeId: item.likeId,
            onTap: onTap,
          );
        }
        return IconLectureCard(item: item, onTap: () => onTap(context));
      },
    );
  }
}

// ── 강의 카드 공통 ────────────────────────────────────────────────────────────

class TintedPoster extends StatelessWidget {
  final String imageAsset;
  final Widget? bottomOverlay;
  const TintedPoster({super.key, required this.imageAsset, this.bottomOverlay});

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (kLecturePosterWidth * dpr).round();
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: ResizeImage(AssetImage(imageAsset), width: cacheWidth),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
        Positioned.fill(child: ColoredBox(color: Colors.black.withValues(alpha: 0.18))),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.0), Colors.black.withValues(alpha: 0.45)],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),
        if (bottomOverlay != null)
          Positioned(left: 0, right: 0, bottom: 0, child: bottomOverlay!),
      ],
    );
  }
}

class LectureCoverCard extends StatelessWidget {
  final String imageAsset;
  final void Function(BuildContext context) onTap;
  final String likeId;
  const LectureCoverCard({
    super.key,
    required this.imageAsset,
    required this.onTap,
    required this.likeId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Container(
        width: kLecturePosterWidth,
        height: kLecturePosterHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OttColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 14, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            TintedPoster(imageAsset: imageAsset),
            Positioned(top: 8, right: 8, child: EngagementBadges(cardId: likeId)),
          ],
        ),
      ),
    );
  }
}

class IconLectureCard extends StatelessWidget {
  final LectureItem item;
  final VoidCallback onTap;
  const IconLectureCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = subjectStyleOf(item.styleKey ?? item.subjectId);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: kLecturePosterWidth,
        height: kLecturePosterHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OttColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 14, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [style.color, style.color.withValues(alpha: 0.7)],
                ),
              ),
            ),
            Positioned(left: 10, top: 12, child: Icon(style.icon, color: Colors.white, size: 26)),
            Positioned(top: 8, right: 8, child: EngagementBadges(cardId: item.likeId)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 수강후기 ─────────────────────────────────────────────────────────────────

class _ReviewCarousel extends StatelessWidget {
  const _ReviewCarousel();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserReviews.instance,
      builder: (context, _) {
        final allReviews = [...UserReviews.instance.submitted, ...reviews];
        return MarqueeRow(
          height: 132,
          pixelsPerSecond: 32,
          itemBuilder: (context) {
            final cards = List.generate(5, (i) => allReviews[i % allReviews.length]);
            return Row(
              children: [
                for (final review in cards) ...[
                  _ReviewMiniCard(review: review),
                  const SizedBox(width: 12),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _ReviewMiniCard extends StatelessWidget {
  final ReviewItem review;
  const _ReviewMiniCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReviewScreen())),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: OttColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: OttColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14,
                  color: OttColors.accentGold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              review.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, height: 1.3),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                review.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: OttColors.textSecondary, fontWeight: FontWeight.w500, height: 1.35),
              ),
            ),
            Text(
              review.date,
              style: const TextStyle(fontSize: 10.5, color: OttColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 과목별 포스터 카드 (외부에서 참조용으로 유지) ─────────────────────────────

String? subjectCoverImage(String subjectId) {
  switch (subjectId) {
    case 'economic_law':
      return 'assets/images/subject_cover_economic_law.png';
    case 'civil_law':
      return 'assets/images/subject_cover_civil_law.png';
    default:
      return null;
  }
}

class SubjectPosterCard extends StatelessWidget {
  final ExamSubject subject;
  const SubjectPosterCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final style = subjectStyleOf(subject.id);
    final coverImage = subjectCoverImage(subject.id);

    final titleOverlay = Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(subject.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(
            subject.categories.join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: OttColors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SubjectInfoScreen(subjectId: subject.id, subjectName: subject.name)),
      ),
      child: Container(
        width: kLecturePosterWidth,
        height: kLecturePosterHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OttColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 14, offset: const Offset(0, 8))],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (coverImage != null)
              TintedPoster(imageAsset: coverImage)
            else ...[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [style.color, style.color.withValues(alpha: 0.7)],
                  ),
                ),
              ),
              Positioned(left: 10, top: 12, child: Icon(style.icon, color: Colors.white, size: 26)),
              Positioned(left: 0, right: 0, bottom: 0, child: titleOverlay),
            ],
            Positioned(top: 8, right: 8, child: EngagementBadges(cardId: 'subject_${subject.id}')),
          ],
        ),
      ),
    );
  }
}
