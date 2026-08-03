import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/sample_questions.dart';
import '../data/user_progress.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../theme/subject_style.dart';
import '../widgets/app_background.dart';
import '../widgets/highlighted_text.dart';
import 'certificate_menu_screen.dart' show studyScreenRouteName;

const _optionLabels = ['A', 'B', 'C', 'D', 'E'];

/// 10문제마다 보여줄 자극 문구 — 듀오링고식 반복학습의 마일스톤 연출.
const _milestoneMessages = [
  '벌써 10문제! 이 페이스 그대로 가봐요 🔥',
  '힘내세요! 합격이 점점 가까워지고 있습니다.',
  '꾸준함이 곧 실력입니다. 계속 가볼까요?',
  '오늘도 한 걸음 더! 다음 10문제도 화이팅.',
  '집중력 최고예요. 이대로만 쭉 가요!',
];

/// subjectId → 표시용 과목명. 여러 과목이 뒤섞이는 화면(함정 피하기 등)에서
/// 문제별로 정확한 과목명을 UserProgress에 기록하기 위해 사용한다.
const Map<String, String> _kSubjectNamesById = {
  'economic_law': '경제법',
  'civil_law': '민법',
  'business_admin': '경영학',
};

class QuizScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  /// 지정하면 해당 챕터(유형)의 문제만 필터링해서 보여준다.
  final String? category;

  /// 지정하면 같은 category 안에서도 이 하위 유형(subTopic)의 문제만 필터링한다.
  final String? subTopic;

  /// 지정하면 subjectId 대신 이 목록에 속한 여러 과목의 문제를 함께 섞어서 보여준다
  /// (예: 함정 피하기처럼 여러 과목을 넘나드는 모드). 이때 widget.subjectId/subjectName은
  /// 화면 스타일(색상)·빈 상태 안내용으로만 쓰이고, 실제 학습기록은 문제별 실제 과목으로 저장된다.
  final List<String>? crossSubjectIds;

  const QuizScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    this.category,
    this.subTopic,
    this.crossSubjectIds,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<Question> _questions;
  int _current = 0;
  int? _selectedIndex;
  bool _answered = false;
  int _solvedInSession = 0;
  int _correctInRound = 0;
  bool _sessionComplete = false;

  final DateTime _startedAt = DateTime.now();
  int _committedSeconds = 0;
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    final crossIds = widget.crossSubjectIds;
    _questions = sampleQuestions
        .where((q) =>
            (crossIds != null ? crossIds.contains(q.subjectId) : q.subjectId == widget.subjectId) &&
            (widget.category == null || q.category == widget.category) &&
            (widget.subTopic == null || q.subTopic == widget.subTopic))
        .toList();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _commitElapsedSeconds();
    super.dispose();
  }

  Duration get _elapsed => DateTime.now().difference(_startedAt);

  String get _elapsedLabel {
    final total = _elapsed.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// 아직 학습시간에 반영되지 않은 경과 시간만 UserProgress에 누적한다 (끝내기·뒤로가기 양쪽에서 안전하게 호출 가능).
  void _commitElapsedSeconds() {
    final elapsedSeconds = _elapsed.inSeconds;
    final delta = elapsedSeconds - _committedSeconds;
    if (delta > 0) {
      UserProgress.instance.addStudySeconds(delta);
      _committedSeconds = elapsedSeconds;
    }
  }

  void _select(int index) {
    if (_answered) return;
    final question = _questions[_current];
    final correct = index == question.correctIndex;
    if (correct) {
      _correctInRound++;
    } else {
      UserProgress.instance.markWrong(question.id);
    }
    UserProgress.instance.recordAnswer(
      subjectId: widget.crossSubjectIds != null ? question.subjectId : widget.subjectId,
      subjectName: widget.crossSubjectIds != null
          ? (_kSubjectNamesById[question.subjectId] ?? widget.subjectName)
          : widget.subjectName,
      category: question.category,
      correct: correct,
    );
    setState(() {
      _selectedIndex = index;
      _answered = true;
      _solvedInSession++;
    });
    if (_solvedInSession % 10 == 0) {
      final message = _milestoneMessages[(_solvedInSession ~/ 10 - 1) % _milestoneMessages.length];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showMilestone(message);
      });
    }
  }

  void _showMilestone(String message) {
    final style = subjectStyleOf(widget.subjectId);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _MilestoneDialog(
        count: _solvedInSession,
        message: message,
        color: style.color,
        onContinue: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  void _next() {
    if (_current + 1 >= _questions.length) {
      setState(() => _sessionComplete = true);
      return;
    }
    setState(() {
      _current++;
      _selectedIndex = null;
      _answered = false;
    });
  }

  /// 복습하기 — 문제 순서를 다시 섞어서 처음부터 풀어보게 한다.
  void _restartShuffled() {
    setState(() {
      _questions.shuffle();
      _current = 0;
      _selectedIndex = null;
      _answered = false;
      _sessionComplete = false;
      _correctInRound = 0;
    });
  }

  /// 끝내기 — 학습시간을 확정 저장하고 "학습하기" 탭의 과목 메뉴로 돌아간다.
  void _finish() {
    _commitElapsedSeconds();
    final navigator = Navigator.of(context);
    // "학습하기" 화면(StudyScreen)까지만 되돌아간다. 해당 라우트가 없는 경우
    // (예: 테스트에서 QuizScreen을 단독 루트로 띄운 경우)에는 첫 화면까지 돌아간다.
    if (navigator.canPop()) {
      navigator.popUntil(ModalRoute.withName(studyScreenRouteName));
    }
  }

  /// 같은 subTopic(세부 유형) 안에서 현재 문제가 몇 번째인지 — 듀오링고 방식의 묶음 반복 학습 표시용.
  int get _subTopicPosition {
    final subTopic = _questions[_current].subTopic;
    if (subTopic == null) return 0;
    var pos = 0;
    for (var i = 0; i <= _current; i++) {
      if (_questions[i].subTopic == subTopic) pos++;
    }
    return pos;
  }

  int get _subTopicTotal {
    final subTopic = _questions[_current].subTopic;
    if (subTopic == null) return 0;
    return _questions.where((q) => q.subTopic == subTopic).length;
  }

  @override
  Widget build(BuildContext context) {
    final style = subjectStyleOf(widget.subjectId);

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category ?? widget.subjectName)),
        body: AppBackground(
          child: Center(
            child: Text(
              widget.category == null ? '아직 이 과목의 샘플 문제가 없습니다.' : '이 챕터는 문제 준비 중이에요.\n곧 유사문제가 추가될 예정입니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    final question = _questions[_current];
    final isCorrect = _selectedIndex == question.correctIndex;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: _sessionComplete
              ? _CompletionView(
                  color: style.color,
                  elapsedLabel: _elapsedLabel,
                  correct: _correctInRound,
                  total: _questions.length,
                  onReview: _restartShuffled,
                  onFinish: _finish,
                )
              : Column(
                  children: [
                    _DuoTopBar(
                      current: _current,
                      total: _questions.length,
                      solved: _solvedInSession,
                      elapsedLabel: _elapsedLabel,
                      color: style.color,
                      onClose: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _DuoQuestionBlock(
                                  question: question,
                                  color: style.color,
                                  subTopicPosition: _subTopicPosition,
                                  subTopicTotal: _subTopicTotal,
                                ),
                                const SizedBox(height: 22),
                                ...List.generate(question.choices.length, (i) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _OptionTile(
                                      label: _optionLabels[i],
                                      text: question.choices[i],
                                      state: _optionState(i, question.correctIndex),
                                      onTap: () => _select(i),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: !_answered,
                              child: AnimatedSlide(
                                key: ValueKey(_current),
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOutCubic,
                                offset: _answered ? Offset.zero : const Offset(0, 1),
                                child: _answered
                                    ? _DuoFeedbackSheet(
                                        isCorrect: isCorrect,
                                        question: question,
                                        color: style.color,
                                        onNext: _next,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  _OptionState _optionState(int index, int correctIndex) {
    if (!_answered) {
      return _selectedIndex == index ? _OptionState.selected : _OptionState.idle;
    }
    if (index == correctIndex) return _OptionState.correct;
    if (index == _selectedIndex) return _OptionState.wrong;
    return _OptionState.disabled;
  }
}

/// 상단 바 — 닫기 버튼 + 두꺼운 진행바(듀오링고 스타일) + 타이머.
class _DuoTopBar extends StatelessWidget {
  final int current;
  final int total;
  final int solved;
  final String elapsedLabel;
  final Color color;
  final VoidCallback onClose;

  const _DuoTopBar({
    required this.current,
    required this.total,
    required this.solved,
    required this.elapsedLabel,
    required this.color,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textMuted,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.trackBg,
                  shape: const CircleBorder(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (current + 1) / total,
                    minHeight: 14,
                    backgroundColor: AppColors.trackBg,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.trackBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_rounded, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      elapsedLabel,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 44),
              Text(
                '${current + 1} / $total',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
              ),
              const Spacer(),
              Text(
                '이번 회차 $solved문제 풀이 중',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 문제 텍스트 블록 — 카드 테두리 없이 배지 + 큼직한 문제 텍스트를 배경 위에 바로 배치한다.
class _DuoQuestionBlock extends StatelessWidget {
  final Question question;
  final Color color;
  final int subTopicPosition;
  final int subTopicTotal;

  const _DuoQuestionBlock({
    required this.question,
    required this.color,
    this.subTopicPosition = 0,
    this.subTopicTotal = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
              child: Text(
                question.category,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5),
              ),
            ),
            if (question.sourceYear != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${question.sourceYear}년 기출',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            if (question.subTopic != null && subTopicTotal > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${question.subTopic} 집중 $subTopicPosition/$subTopicTotal',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          question.stem,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.45,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

enum _OptionState { idle, selected, correct, wrong, disabled }

/// 보기 버튼 — 아래쪽 테두리를 두껍게 줘서 눌리는 입체감(듀오링고 스타일 3D 버튼)을 흉내낸다.
class _OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionTile({required this.label, required this.text, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFFE1E1E8);
    Color fillColor = Colors.white;
    Color badgeBg = AppColors.trackBg;
    Color badgeFg = AppColors.textSecondary;
    Widget? trailing;
    double opacity = 1;

    switch (state) {
      case _OptionState.selected:
        borderColor = AppColors.primary;
        fillColor = AppColors.primary.withValues(alpha: 0.06);
        badgeBg = AppColors.primary;
        badgeFg = Colors.white;
        break;
      case _OptionState.correct:
        borderColor = AppColors.correct;
        fillColor = AppColors.correct.withValues(alpha: 0.12);
        badgeBg = AppColors.correct;
        badgeFg = Colors.white;
        trailing = const Icon(Icons.check_circle_rounded, color: AppColors.correct, size: 24);
        break;
      case _OptionState.wrong:
        borderColor = AppColors.wrong;
        fillColor = AppColors.wrong.withValues(alpha: 0.12);
        badgeBg = AppColors.wrong;
        badgeFg = Colors.white;
        trailing = const Icon(Icons.cancel_rounded, color: AppColors.wrong, size: 24);
        break;
      case _OptionState.disabled:
        opacity = 0.5;
        break;
      case _OptionState.idle:
        break;
    }

    return Opacity(
      opacity: opacity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: borderColor, width: 2),
            top: BorderSide(color: borderColor, width: 2),
            right: BorderSide(color: borderColor, width: 2),
            bottom: BorderSide(color: borderColor, width: 4),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
                    child: Text(label, style: TextStyle(color: badgeFg, fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 18.5, height: 1.35, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 8), trailing],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 정답 확인 후 화면 하단에서 올라오는 고정 패널(듀오링고 스타일 바텀시트).
/// 해설이 길어도 안의 스크롤 영역만 늘어나고, "다음 유사문제" 버튼은 항상 하단에 고정된다.
class _DuoFeedbackSheet extends StatelessWidget {
  final bool isCorrect;
  final Question question;
  final Color color;
  final VoidCallback onNext;

  const _DuoFeedbackSheet({
    required this.isCorrect,
    required this.question,
    required this.color,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final resultColor = isCorrect ? AppColors.correct : AppColors.wrong;
    final panelBg = isCorrect ? const Color(0xFFE3F8E9) : const Color(0xFFFFE9E7);
    final panelHeight = math.min(360.0, MediaQuery.sizeOf(context).height * 0.5);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: panelHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: panelBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: resultColor.withValues(alpha: 0.5), width: 2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, -6)),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(color: resultColor, shape: BoxShape.circle),
                          child: Icon(
                            isCorrect ? Icons.check_rounded : Icons.close_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isCorrect ? '정답이에요!' : '아쉬워요, 오답이에요',
                            style: TextStyle(color: resultColor, fontWeight: FontWeight.w900, fontSize: 19),
                          ),
                        ),
                        ListenableBuilder(
                          listenable: UserProgress.instance,
                          builder: (context, _) {
                            final compiled = UserProgress.instance.isCompiled(question.id);
                            return IconButton(
                              onPressed: () => UserProgress.instance.toggleCompiled(question.id),
                              icon: Icon(
                                compiled ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                color: compiled ? AppColors.primary : AppColors.textMuted,
                              ),
                              tooltip: '단권화 노트에 저장',
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '해설',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: resultColor, letterSpacing: 0.4),
                    ),
                    const SizedBox(height: 6),
                    HighlightedText(
                      text: question.summaryExplanation,
                      phrases: question.highlightPhrases,
                      style: const TextStyle(fontSize: 17, height: 1.6, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    ),
                    if (question.keyPoints.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        '핵심 개념',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: resultColor, letterSpacing: 0.4),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: question.keyPoints
                            .map((k) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: resultColor.withValues(alpha: 0.35)),
                                  ),
                                  child: Text(
                                    k,
                                    style: TextStyle(color: resultColor, fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: resultColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('다음 유사문제', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 문제를 다 풀었을 때 보여주는 완료 화면 — 복습하기(순서 섞어서 재도전) / 끝내기(과목 메뉴로 이동).
class _CompletionView extends StatelessWidget {
  final Color color;
  final String elapsedLabel;
  final int correct;
  final int total;
  final VoidCallback onReview;
  final VoidCallback onFinish;

  const _CompletionView({
    required this.color,
    required this.elapsedLabel,
    required this.correct,
    required this.total,
    required this.onReview,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final accuracyPercent = total == 0 ? 0 : (correct / total * 100).round();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
              ),
              child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              '문제를 다 풀었어요!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _CompletionStat(icon: Icons.timer_outlined, label: '걸린 시간', value: elapsedLabel, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompletionStat(
                    icon: Icons.task_alt_rounded,
                    label: '정답',
                    value: '$correct / $total ($accuracyPercent%)',
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color, width: 1.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: onReview,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('복습하기', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: onFinish,
                icon: const Icon(Icons.check_rounded),
                label: const Text('끝내기', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _CompletionStat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// 10문제 달성마다 뜨는 응원 다이얼로그 — 듀오링고식 반복학습 마일스톤 연출.
class _MilestoneDialog extends StatelessWidget {
  final int count;
  final String message;
  final Color color;
  final VoidCallback onContinue;

  const _MilestoneDialog({
    required this.count,
    required this.message,
    required this.color,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 12)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
              ),
              child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              '$count문제 달성!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14.5, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onContinue,
                child: const Text('계속 풀기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
