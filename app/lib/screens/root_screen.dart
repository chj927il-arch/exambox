import 'package:flutter/material.dart';
import '../data/sample_questions.dart';
import '../data/topic_stats.dart';
import '../models/exam_subject.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../theme/subject_style.dart';
import 'full_mock_exam_screen.dart';
import 'quiz_screen.dart';
import 'time_attack_screen.dart';

// ── 상수 ────────────────────────────────────────────────────────────────────

const double _kSidebarWidth = 260.0;

// ── 루트 화면 ────────────────────────────────────────────────────────────────

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  String? _selSubjectId;
  String? _selTopic;
  final Set<String> _expanded = {'economic_law'};
  bool _collapsed = false;

  void _selectTopic(String subjectId, String topic) {
    setState(() {
      _selSubjectId = subjectId;
      _selTopic = topic;
    });
  }

  void _clearSelection() {
    setState(() {
      _selSubjectId = null;
      _selTopic = null;
    });
  }

  void _toggleExpand(String subjectId) {
    setState(() {
      if (_expanded.contains(subjectId)) {
        _expanded.remove(subjectId);
      } else {
        _expanded.add(subjectId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isDesktop = w >= kDesktopBreakpoint;

    if (!isDesktop) {
      // 모바일: 기존 QuizScreen으로 바로 진입
      return _MobileShell(
        selSubjectId: _selSubjectId,
        selTopic: _selTopic,
        expanded: _expanded,
        onSelectTopic: _selectTopic,
        onToggleExpand: _toggleExpand,
        onClearSelection: _clearSelection,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FA),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 사이드바
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: _collapsed ? 0 : _kSidebarWidth,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(),
            child: _Sidebar(
              expanded: _expanded,
              selSubjectId: _selSubjectId,
              selTopic: _selTopic,
              onSelectTopic: _selectTopic,
              onToggleExpand: _toggleExpand,
              onClearSelection: _clearSelection,
              onQuickAccess: _handleQuickAccess,
            ),
          ),
          // 사이드바 토글 버튼
          _SidebarToggle(
            collapsed: _collapsed,
            onTap: () => setState(() => _collapsed = !_collapsed),
          ),
          // 메인 콘텐츠
          Expanded(
            child: _selTopic != null
                ? _ChapterQuestionsView(
                    key: ValueKey('$_selSubjectId/$_selTopic'),
                    subjectId: _selSubjectId!,
                    topic: _selTopic!,
                  )
                : const _OverviewView(),
          ),
        ],
      ),
    );
  }

  void _handleQuickAccess(String key) {
    setState(() {
      _selSubjectId = null;
      _selTopic = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = context;
      if (!ctx.mounted) return;
      switch (key) {
        case 'mock_exam':
          Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const FullMockExamScreen()));
        case 'time_attack':
          Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const TimeAttackScreen()));
        case 'trap':
          Navigator.of(ctx).push(MaterialPageRoute(
            builder: (_) => const QuizScreen(
              subjectId: 'trap_quiz_season1',
              subjectName: '틀리기 쉬운 문제 시즌1',
              category: '함정 피하기',
              crossSubjectIds: ['economic_law', 'civil_law', 'business_admin'],
            ),
          ));
      }
    });
  }
}

// ── 사이드바 토글 버튼 ────────────────────────────────────────────────────────

class _SidebarToggle extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onTap;
  const _SidebarToggle({required this.collapsed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            right: BorderSide(color: AppColors.glassBorder),
            left: BorderSide(color: AppColors.glassBorder),
          ),
        ),
        child: Icon(
          collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
          size: 16,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

// ── 사이드바 ─────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final Set<String> expanded;
  final String? selSubjectId;
  final String? selTopic;
  final void Function(String subjectId, String topic) onSelectTopic;
  final void Function(String subjectId) onToggleExpand;
  final VoidCallback onClearSelection;
  final void Function(String key) onQuickAccess;

  const _Sidebar({
    required this.expanded,
    required this.selSubjectId,
    required this.selTopic,
    required this.onSelectTopic,
    required this.onToggleExpand,
    required this.onClearSelection,
    required this.onQuickAccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kSidebarWidth,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 브랜드 헤더
          InkWell(
            onTap: onClearSelection,
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '스터디박스',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3),
                      ),
                      Text(
                        '가맹거래사 1차',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 스크롤 가능한 네비게이션
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _SidebarLabel('실전 연습'),
                _NavBtn(
                  icon: Icons.assignment_outlined,
                  label: '실전모의고사',
                  color: const Color(0xFF3B5BFF),
                  isActive: false,
                  onTap: () => onQuickAccess('mock_exam'),
                ),
                _NavBtn(
                  icon: Icons.timer_outlined,
                  label: '타임어택',
                  color: const Color(0xFFD4890A),
                  isActive: false,
                  onTap: () => onQuickAccess('time_attack'),
                ),
                _NavBtn(
                  icon: Icons.warning_amber_outlined,
                  label: '틀리기 쉬운 문제',
                  color: const Color(0xFFD93025),
                  isActive: false,
                  onTap: () => onQuickAccess('trap'),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: AppColors.glassBorder),
                const SizedBox(height: 8),
                _SidebarLabel('과목별 학습'),
                for (final subject in examSubjects)
                  _SubjectExpander(
                    subject: subject,
                    isExpanded: expanded.contains(subject.id),
                    selTopic: selSubjectId == subject.id ? selTopic : null,
                    onToggle: () => onToggleExpand(subject.id),
                    onTopicTap: (topic) => onSelectTopic(subject.id, topic),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarLabel extends StatelessWidget {
  final String text;
  const _SidebarLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;
  const _NavBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: isActive ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Icon(icon, color: isActive ? AppColors.primary : color, size: 17),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectExpander extends StatelessWidget {
  final ExamSubject subject;
  final bool isExpanded;
  final String? selTopic;
  final VoidCallback onToggle;
  final void Function(String topic) onTopicTap;

  const _SubjectExpander({
    required this.subject,
    required this.isExpanded,
    required this.selTopic,
    required this.onToggle,
    required this.onTopicTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = subjectStyleOf(subject.id);
    final chapters = chapterStatsFor(subject.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 과목 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                child: Row(
                  children: [
                    Icon(style.icon, color: style.color, size: 17),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        subject.name,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 챕터 목록
        if (isExpanded)
          ...chapters.map((ch) {
            final isActive = selTopic == ch.topic;
            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 10, top: 1, bottom: 1),
              child: Material(
                color: isActive ? style.color.withValues(alpha: 0.10) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onTopicTap(ch.topic),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    child: Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(right: 9),
                          decoration: BoxDecoration(
                            color: isActive ? style.color : AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ch.topic,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isActive ? style.color : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          '${ch.questionCount}문',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isActive ? style.color.withValues(alpha: 0.7) : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

// ── 개요 화면 (챕터 미선택시) ──────────────────────────────────────────────────

class _OverviewView extends StatelessWidget {
  const _OverviewView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '스터디박스',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          const Text(
            '가맹거래사 1차 시험 · 민법 · 경제법 · 경영학',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 36),
          const Text(
            '과목 현황',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: examSubjects.map((s) {
              final style = subjectStyleOf(s.id);
              final chapters = chapterStatsFor(s.id);
              final total = chapters.fold(0, (sum, c) => sum + c.questionCount);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: s == examSubjects.last ? 0 : 16),
                  child: _SubjectStatCard(subject: s, style: style, chapterCount: chapters.length, questionCount: total),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Text(
            '실전 연습',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickCard(
                icon: Icons.assignment_outlined,
                label: '실전모의고사',
                desc: '전범위 70문항 실전 시험',
                color: const Color(0xFF3B5BFF),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FullMockExamScreen())),
              ),
              const SizedBox(width: 16),
              _QuickCard(
                icon: Icons.timer_outlined,
                label: '타임어택',
                desc: '1분 제한 스피드 풀기',
                color: const Color(0xFFD4890A),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TimeAttackScreen())),
              ),
              const SizedBox(width: 16),
              _QuickCard(
                icon: Icons.warning_amber_outlined,
                label: '틀리기 쉬운 문제',
                desc: '함정 유형 집중 풀이',
                color: const Color(0xFFD93025),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const QuizScreen(
                    subjectId: 'trap_quiz_season1',
                    subjectName: '틀리기 쉬운 문제 시즌1',
                    category: '함정 피하기',
                    crossSubjectIds: ['economic_law', 'civil_law', 'business_admin'],
                  ),
                )),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '왼쪽 사이드바에서 과목 → 챕터를 선택하면 해당 유형의 문제를 목록으로 볼 수 있어요.',
                    style: TextStyle(fontSize: 13.5, color: AppColors.primaryDark, fontWeight: FontWeight.w600, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectStatCard extends StatelessWidget {
  final ExamSubject subject;
  final SubjectStyle style;
  final int chapterCount;
  final int questionCount;

  const _SubjectStatCard({
    required this.subject,
    required this.style,
    required this.chapterCount,
    required this.questionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: style.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
                child: Icon(style.icon, color: style.color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(subject.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatPill('$chapterCount챕터', style.color),
              const SizedBox(width: 8),
              _StatPill('$questionCount문항', AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatPill(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final VoidCallback onTap;
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 12),
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 챕터 문제 목록 화면 ───────────────────────────────────────────────────────

enum _QuestionViewMode { card, paper }

class _ChapterQuestionsView extends StatefulWidget {
  final String subjectId;
  final String topic;
  const _ChapterQuestionsView({required this.subjectId, required this.topic, super.key});

  @override
  State<_ChapterQuestionsView> createState() => _ChapterQuestionsViewState();
}

class _ChapterQuestionsViewState extends State<_ChapterQuestionsView> {
  _QuestionViewMode _mode = _QuestionViewMode.card;

  @override
  Widget build(BuildContext context) {
    final style = subjectStyleOf(widget.subjectId);
    final questions = sampleQuestions.where((q) => q.subjectId == widget.subjectId && q.category == widget.topic).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 헤더
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: style.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(style.icon, color: style.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.topic,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3),
                    ),
                    Text(
                      questions.isEmpty ? '문제 준비 중' : '${questions.length}문항',
                      style: TextStyle(fontSize: 13, color: style.color, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              // 모드 토글
              if (questions.isNotEmpty)
                _ModeToggle(
                  mode: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                ),
            ],
          ),
        ),
        // 문제 내용
        Expanded(
          child: questions.isEmpty
              ? const _EmptyChapter()
              : _mode == _QuestionViewMode.card
                  ? ListView.builder(
                      padding: const EdgeInsets.all(32),
                      itemCount: questions.length,
                      itemBuilder: (context, i) => _QuestionCard(question: questions[i], number: i + 1, subjectStyle: style),
                    )
                  : _ExamPaperView(
                      key: ValueKey('paper/${widget.subjectId}/${widget.topic}'),
                      questions: questions,
                      subjectName: examSubjects.firstWhere((s) => s.id == widget.subjectId).name,
                      topic: widget.topic,
                      style: style,
                    ),
        ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final _QuestionViewMode mode;
  final void Function(_QuestionViewMode) onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            icon: Icons.view_list_rounded,
            label: '카드 풀기',
            active: mode == _QuestionViewMode.card,
            onTap: () => onChanged(_QuestionViewMode.card),
          ),
          _ToggleBtn(
            icon: Icons.article_outlined,
            label: '문제지 모드',
            active: mode == _QuestionViewMode.paper,
            onTap: () => onChanged(_QuestionViewMode.paper),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ToggleBtn({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 6, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? AppColors.primary : AppColors.textMuted),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 시험지 모드 ───────────────────────────────────────────────────────────────

class _ExamPaperView extends StatefulWidget {
  final List<Question> questions;
  final String subjectName;
  final String topic;
  final SubjectStyle style;
  const _ExamPaperView({
    required this.questions,
    required this.subjectName,
    required this.topic,
    required this.style,
    super.key,
  });

  @override
  State<_ExamPaperView> createState() => _ExamPaperViewState();
}

class _ExamPaperViewState extends State<_ExamPaperView> {
  final Map<int, int> _answers = {}; // index → selected choice index
  bool _submitted = false;

  int get _correct => _answers.entries.where((e) => widget.questions[e.key].correctIndex == e.value).length;

  void _submit() {
    setState(() => _submitted = true);
  }

  void _reset() {
    setState(() {
      _answers.clear();
      _submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.questions;
    final allAnswered = _answers.length == questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              // A4 시험지
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8)),
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 시험지 헤더
                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 32, 40, 24),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '가맹거래사 1차 시험',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade500,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.subjectName,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF111111),
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.topic,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: widget.style.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 점수 표시 (채점 후)
                              if (_submitted)
                                _ScoreBadge(correct: _correct, total: questions.length)
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${questions.length}문항',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
                                  ),
                                ),
                            ],
                          ),
                          if (_submitted) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: _correct == questions.length
                                    ? AppColors.correct.withValues(alpha: 0.08)
                                    : _correct >= questions.length * 0.6
                                        ? const Color(0xFFFFF3CD)
                                        : AppColors.wrong.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _correct == questions.length
                                      ? AppColors.correct.withValues(alpha: 0.25)
                                      : _correct >= questions.length * 0.6
                                          ? const Color(0xFFE6C200)
                                          : AppColors.wrong.withValues(alpha: 0.20),
                                ),
                              ),
                              child: Text(
                                _correct == questions.length
                                    ? '완벽합니다! 모든 문제를 맞혔어요 🎉'
                                    : _correct >= questions.length * 0.6
                                        ? '${questions.length - _correct}문제를 틀렸어요. 해설을 확인하세요.'
                                        : '${questions.length - _correct}문제 오답 — 해당 유형을 다시 복습해보세요.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _correct == questions.length
                                      ? AppColors.correct
                                      : _correct >= questions.length * 0.6
                                          ? const Color(0xFF8A6800)
                                          : AppColors.wrong,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // 문제들
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 28, 40, 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(questions.length, (i) {
                          return _ExamQuestion(
                            question: questions[i],
                            number: i + 1,
                            selectedIndex: _answers[i],
                            submitted: _submitted,
                            onSelect: _submitted ? null : (ci) => setState(() => _answers[i] = ci),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 하단 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_submitted) ...[
                    OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('다시 풀기'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        side: const BorderSide(color: AppColors.glassBorder),
                        foregroundColor: AppColors.textSecondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ] else ...[
                    if (!allAnswered)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          '${_answers.length}/${questions.length} 문항 선택됨',
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                        ),
                      ),
                    FilledButton.icon(
                      onPressed: allAnswered ? _submit : null,
                      icon: const Icon(Icons.grading_rounded, size: 16),
                      label: const Text('채점하기'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.glassBorder,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int correct;
  final int total;
  const _ScoreBadge({required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (correct * 100 ~/ total);
    final color = pct >= 80
        ? AppColors.correct
        : pct >= 60
            ? const Color(0xFFD4890A)
            : AppColors.wrong;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        children: [
          Text(
            '$correct/$total',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color),
          ),
          Text('$pct점', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

// ── 시험지 문항 ───────────────────────────────────────────────────────────────

const _kCircledNums = ['①', '②', '③', '④', '⑤', '⑥', '⑦', '⑧'];

class _ExamQuestion extends StatelessWidget {
  final Question question;
  final int number;
  final int? selectedIndex;
  final bool submitted;
  final void Function(int)? onSelect;

  const _ExamQuestion({
    required this.question,
    required this.number,
    required this.selectedIndex,
    required this.submitted,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final q = question;
    final isCorrect = submitted && selectedIndex == q.correctIndex;
    final isWrong = submitted && selectedIndex != null && selectedIndex != q.correctIndex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 문제 번호 + 문제
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 원
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 1, right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: submitted
                      ? (isCorrect ? AppColors.correct : isWrong ? AppColors.wrong : const Color(0xFF888888))
                      : const Color(0xFF333333),
                  border: submitted && !isCorrect && !isWrong
                      ? null
                      : null,
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.stem,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                        height: 1.6,
                      ),
                    ),
                    if (q.sourceYear != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '[${q.sourceYear}년 기출]',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 선택지
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(q.choices.length, (i) {
                final circled = i < _kCircledNums.length ? _kCircledNums[i] : '${i + 1}.';
                final isSelected = selectedIndex == i;
                final isAnswer = i == q.correctIndex;

                Color textColor = const Color(0xFF222222);
                Color? bgColor;
                FontWeight fw = FontWeight.w400;

                if (submitted) {
                  if (isAnswer) {
                    textColor = AppColors.correct;
                    bgColor = AppColors.correct.withValues(alpha: 0.07);
                    fw = FontWeight.w700;
                  } else if (isSelected && !isAnswer) {
                    textColor = AppColors.wrong;
                    bgColor = AppColors.wrong.withValues(alpha: 0.06);
                    fw = FontWeight.w600;
                  } else {
                    textColor = Colors.grey.shade400;
                  }
                } else if (isSelected) {
                  textColor = AppColors.primary;
                  bgColor = AppColors.primarySoft;
                  fw = FontWeight.w600;
                }

                return GestureDetector(
                  onTap: onSelect != null ? () => onSelect!(i) : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          circled,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: submitted
                                ? (isAnswer ? AppColors.correct : isSelected ? AppColors.wrong : Colors.grey.shade400)
                                : isSelected
                                    ? AppColors.primary
                                    : const Color(0xFF444444),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            q.choices[i],
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: fw,
                              color: textColor,
                              height: 1.5,
                            ),
                          ),
                        ),
                        if (submitted && isAnswer)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.check_circle, color: AppColors.correct, size: 16),
                          ),
                        if (submitted && isSelected && !isAnswer)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.cancel, color: AppColors.wrong, size: 16),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          // 해설 (채점 후, 오답인 경우)
          if (submitted && isWrong && q.summaryExplanation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Text(
                        q.summaryExplanation,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF5D4037), height: 1.55, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 구분선
          if (number < 99)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Divider(color: Colors.grey.shade200, height: 1),
            ),
        ],
      ),
    );
  }
}

class _EmptyChapter extends StatelessWidget {
  const _EmptyChapter();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction_outlined, size: 48, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text('문제를 준비 중이에요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          SizedBox(height: 6),
          Text('곧 업데이트될 예정입니다', style: TextStyle(fontSize: 13.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ── 문제 카드 (인라인 풀기) ───────────────────────────────────────────────────

class _QuestionCard extends StatefulWidget {
  final Question question;
  final int number;
  final SubjectStyle subjectStyle;
  const _QuestionCard({required this.question, required this.number, required this.subjectStyle});

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  int? _selected;
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final isCorrect = _selected == q.correctIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _revealed ? (isCorrect ? AppColors.correct.withValues(alpha: 0.3) : AppColors.wrong.withValues(alpha: 0.3)) : AppColors.glassBorder,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 문제 상단
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: widget.subjectStyle.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.number}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: widget.subjectStyle.color),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    q.stem,
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.55),
                  ),
                ),
                if (q.sourceYear != null)
                  Container(
                    margin: const EdgeInsets.only(left: 12, top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${q.sourceYear}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 선택지
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: List.generate(q.choices.length, (i) {
                final isSelected = _selected == i;
                final isAnswer = i == q.correctIndex;
                Color? bg;
                Color borderColor = AppColors.glassBorder;
                Color textColor = AppColors.textPrimary;
                if (_revealed) {
                  if (isAnswer) {
                    bg = AppColors.correct.withValues(alpha: 0.10);
                    borderColor = AppColors.correct.withValues(alpha: 0.45);
                    textColor = AppColors.correct;
                  } else if (isSelected && !isAnswer) {
                    bg = AppColors.wrong.withValues(alpha: 0.08);
                    borderColor = AppColors.wrong.withValues(alpha: 0.40);
                    textColor = AppColors.wrong;
                  }
                } else if (isSelected) {
                  bg = AppColors.primarySoft;
                  borderColor = AppColors.primary.withValues(alpha: 0.45);
                  textColor = AppColors.primary;
                }
                return GestureDetector(
                  onTap: _revealed ? null : () => setState(() => _selected = i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: bg ?? const Color(0xFFFAFAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected || (_revealed && isAnswer)
                                ? (textColor.withValues(alpha: 0.15))
                                : const Color(0xFFEDEDF1),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: isSelected || (_revealed && isAnswer) ? textColor : AppColors.textMuted),
                          ),
                        ),
                        Expanded(
                          child: Text(q.choices[i], style: TextStyle(fontSize: 14.5, color: textColor, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, height: 1.4)),
                        ),
                        if (_revealed && isAnswer)
                          const Icon(Icons.check_circle_rounded, color: AppColors.correct, size: 18),
                        if (_revealed && isSelected && !isAnswer)
                          const Icon(Icons.cancel_rounded, color: AppColors.wrong, size: 18),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          // 정답 확인 버튼 or 해설
          if (!_revealed) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton(
                  onPressed: _selected != null ? () => setState(() => _revealed = true) : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _selected != null ? AppColors.primary : AppColors.glassBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('정답 확인', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ),
          ] else ...[
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCorrect ? AppColors.correct.withValues(alpha: 0.06) : AppColors.wrong.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isCorrect ? AppColors.correct.withValues(alpha: 0.20) : AppColors.wrong.withValues(alpha: 0.20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
                        color: isCorrect ? AppColors.correct : AppColors.wrong,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCorrect ? '정답입니다!' : '오답 — 정답은 ${q.correctIndex + 1}번',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isCorrect ? AppColors.correct : AppColors.wrong,
                        ),
                      ),
                    ],
                  ),
                  if (q.summaryExplanation.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFDDE0E8)),
                    const SizedBox(height: 10),
                    Text(
                      q.summaryExplanation,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.65, fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 모바일 쉘 (간략) ─────────────────────────────────────────────────────────

class _MobileShell extends StatefulWidget {
  final String? selSubjectId;
  final String? selTopic;
  final Set<String> expanded;
  final void Function(String, String) onSelectTopic;
  final void Function(String) onToggleExpand;
  final VoidCallback onClearSelection;

  const _MobileShell({
    required this.selSubjectId,
    required this.selTopic,
    required this.expanded,
    required this.onSelectTopic,
    required this.onToggleExpand,
    required this.onClearSelection,
  });

  @override
  State<_MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<_MobileShell> {
  @override
  Widget build(BuildContext context) {
    if (widget.selTopic != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.selTopic!),
          leading: BackButton(onPressed: widget.onClearSelection),
        ),
        body: _ChapterQuestionsView(
          key: ValueKey('${widget.selSubjectId}/${widget.selTopic}'),
          subjectId: widget.selSubjectId!,
          topic: widget.selTopic!,
        ),
      );
    }

    // 모바일 홈: 과목 → 챕터 선택
    return Scaffold(
      appBar: AppBar(title: const Text('스터디박스'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('과목을 선택해주세요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          for (final subject in examSubjects) ...[
            _MobileSubjectTile(
              subject: subject,
              isExpanded: widget.expanded.contains(subject.id),
              selTopic: widget.selSubjectId == subject.id ? widget.selTopic : null,
              onToggle: () => widget.onToggleExpand(subject.id),
              onTopicTap: (topic) => widget.onSelectTopic(subject.id, topic),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _MobileSubjectTile extends StatelessWidget {
  final ExamSubject subject;
  final bool isExpanded;
  final String? selTopic;
  final VoidCallback onToggle;
  final void Function(String) onTopicTap;

  const _MobileSubjectTile({
    required this.subject,
    required this.isExpanded,
    required this.selTopic,
    required this.onToggle,
    required this.onTopicTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = subjectStyleOf(subject.id);
    final chapters = chapterStatsFor(subject.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: style.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(style.icon, color: style.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(subject.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                  Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          if (isExpanded)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: chapters.length,
              itemBuilder: (context, i) {
                final ch = chapters[i];
                return InkWell(
                  onTap: () => onTopicTap(ch.topic),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.glassBorder))),
                    child: Row(
                      children: [
                        const SizedBox(width: 50),
                        Expanded(child: Text(ch.topic, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
                        Text('${ch.questionCount}문', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
