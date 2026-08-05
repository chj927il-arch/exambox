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

const _optionLabels = ['①', '②', '③', '④', '⑤'];

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
  'korean_history': '한능검',
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
  int _solvedInSession = 0;
  int _correctInRound = 0;
  bool _sessionComplete = false;

  /// 문제별 채점 결과 — true(정답)/false(오답)/null(아직 안 풂). 문제 목록에서
  /// 몇 번을 맞혔는지 보여주고, 특정 문제로 바로 이동했을 때도 기록이 유지되게 한다.
  late final List<bool?> _results;

  /// 문제별로 고른 보기 — 데스크톱 2분할 화면에서는 두 문제를 동시에 각자 풀 수 있어야 해서
  /// (한쪽이 회색으로 잠겨있으면 안 됨) 단일 "현재 선택"이 아니라 문제별로 따로 기억한다.
  late final List<int?> _selected;

  /// 한 번 "해설 보기"를 눌러 펼친 문제는 인덱스로 기억해 다시 봐도 접히지 않게 한다.
  final Set<int> _explanationRevealed = {};

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
    _results = List<bool?>.filled(_questions.length, null);
    _selected = List<int?>.filled(_questions.length, null);
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

  bool _isAnswered(int index) => _selected[index] != null;

  /// [index]번 문제에 [choice]번 보기를 선택한다. 데스크톱 2분할 화면에서는 두 문제가
  /// 각자 독립적으로 풀 수 있어야 해서 index를 받아 문제별로 채점·기록한다.
  void _select(int index, int choice) {
    if (_isAnswered(index)) return;
    final question = _questions[index];
    final correct = choice == question.correctIndex;
    // 목록에서 이미 풀었던 문제로 다시 이동해 열어본 경우(리뷰)에는 통계를 중복 반영하지 않는다.
    final alreadyRecorded = _results[index] != null;
    if (!alreadyRecorded) {
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
    }
    setState(() {
      _results[index] = correct;
      _selected[index] = choice;
      if (!alreadyRecorded) _solvedInSession++;
    });
    if (!alreadyRecorded && _solvedInSession % 10 == 0) {
      final message = _milestoneMessages[(_solvedInSession ~/ 10 - 1) % _milestoneMessages.length];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showMilestone(message);
      });
    }
  }

  /// 문제 목록에서 특정 문제를 탭했을 때 그 문제로 바로 이동한다. 각 문제의 채점 결과는
  /// _selected/_results 배열에 이미 남아있어 별도 복원 없이 그대로 보여진다.
  void _jumpTo(int index) {
    if (index < 0 || index >= _questions.length) return;
    setState(() {
      _current = index;
      _sessionComplete = false;
    });
  }

  /// 그 과목의 첫 문제로 바로 이동한다(함정 피하기처럼 여러 과목이 뒤섞인 세션에서
  /// 상단 과목 탭을 눌렀을 때 쓰인다). 아직 그 과목 문제가 없으면 아무 동작도 하지 않는다.
  void _jumpToSubject(String subjectId) {
    final index = _questions.indexWhere((q) => q.subjectId == subjectId);
    if (index != -1) _jumpTo(index);
  }

  /// 함정 피하기처럼 여러 과목을 넘나드는 세션 상단에 보여줄 과목 구분 탭 — 실제로 이 세션에
  /// 포함된 과목만(문제가 0개인 과목은 제외) 순서대로 보여주고, 현재 보고 있는 과목을 강조한다.
  Widget _buildSubjectTabsBar() {
    final seen = <String>{};
    final subjectIds = <String>[];
    for (final q in _questions) {
      if (seen.add(q.subjectId)) subjectIds.add(q.subjectId);
    }
    final currentSubjectId = _questions[_current].subjectId;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: subjectIds.map((id) {
          final isCurrent = id == currentSubjectId;
          final subjectColor = subjectStyleOf(id).color;
          return Expanded(
            child: GestureDetector(
              onTap: () => _jumpToSubject(id),
              child: Container(
                margin: EdgeInsets.only(right: id == subjectIds.last ? 0 : 8),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isCurrent ? subjectColor : AppColors.trackBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  _kSubjectNamesById[id] ?? id,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isCurrent ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openQuestionList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _QuestionListSheet(
        questions: _questions,
        results: _results,
        current: _current,
        color: subjectStyleOf(widget.subjectId).color,
        onSelect: (index) {
          Navigator.of(context).pop();
          _jumpTo(index);
        },
      ),
    );
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
    setState(() => _current++);
  }

  /// 복습하기 — 문제 순서를 다시 섞어서 처음부터 풀어보게 한다.
  void _restartShuffled() {
    setState(() {
      _questions.shuffle();
      _current = 0;
      _sessionComplete = false;
      _correctInRound = 0;
      _selected.fillRange(0, _selected.length, null);
      _results.fillRange(0, _results.length, null);
      _explanationRevealed.clear();
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

    final isWide = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    // 데스크톱 2분할 화면에서는 항상 짝수 인덱스부터 시작하는 한 쌍(pairStart, pairStart+1)을
    // 보여준다 — 어느 쪽이든 자유롭게(순서 상관없이) 풀 수 있다.
    final pairStart = isWide ? (_current ~/ 2) * 2 : _current;
    final rightIndex = isWide && pairStart + 1 < _questions.length ? pairStart + 1 : null;
    final isLastPair = pairStart + 2 >= _questions.length;
    final topBarIndex = isWide ? pairStart : _current;

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
                      current: topBarIndex,
                      total: _questions.length,
                      solved: _solvedInSession,
                      elapsedLabel: _elapsedLabel,
                      color: style.color,
                      onClose: () => Navigator.of(context).maybePop(),
                      onOpenList: _openQuestionList,
                    ),
                    if (widget.crossSubjectIds != null) _buildSubjectTabsBar(),
                    Expanded(
                      child: isWide
                          ? Column(
                              children: [
                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        // 지문·보기 길이가 좌우로 달라 정답/오답 피드백이 시작되는 줄이 어긋나 보이는
                                        // 문제를 고치기 위해, 문제(지문+보기) 전체의 실제 렌더링 높이를 미리 계산해서
                                        // 짧은 쪽 피드백 위에 그 차이만큼 빈 공간을 채운다(문제 자체는 그대로 둔다).
                                        const numberPrefixWidth = 34.0;
                                        final columnWidth = (constraints.maxWidth - 24 - 1 - 24) / 2;
                                        final leftQuestion = _questions[pairStart];
                                        final rightQuestion = rightIndex != null ? _questions[rightIndex] : null;
                                        final leftHeight = _measureStemHeight(leftQuestion.stem, columnWidth - numberPrefixWidth) +
                                            _measureOptionsHeight(leftQuestion.choices, columnWidth);
                                        final rightHeight = rightQuestion != null
                                            ? _measureStemHeight(rightQuestion.stem, columnWidth - numberPrefixWidth) +
                                                _measureOptionsHeight(rightQuestion.choices, columnWidth)
                                            : 0.0;
                                        final maxHeight = leftHeight > rightHeight ? leftHeight : rightHeight;
                                        return IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: _buildPairColumn(
                                                  pairStart,
                                                  style.color,
                                                  extraFeedbackPadding: maxHeight - leftHeight,
                                                ),
                                              ),
                                              const SizedBox(width: 24),
                                              const VerticalDivider(width: 1, thickness: 1, color: AppColors.glassBorder),
                                              const SizedBox(width: 24),
                                              Expanded(
                                                child: rightIndex != null
                                                    ? _buildPairColumn(
                                                        rightIndex,
                                                        style.color,
                                                        extraFeedbackPadding: maxHeight - rightHeight,
                                                      )
                                                    : const SizedBox.shrink(),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                _buildPairNavBar(pairStart, isLastPair, style.color),
                              ],
                            )
                          : Stack(
                              children: [
                                SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _DuoQuestionBlock(
                                        question: _questions[_current],
                                        color: style.color,
                                        questionNumber: _current + 1,
                                        subTopicPosition: _subTopicPosition,
                                        subTopicTotal: _subTopicTotal,
                                        optionCount: _questions[_current].choices.length,
                                        optionBuilder: (i) => _OptionTile(
                                          label: _optionLabels[i],
                                          text: _questions[_current].choices[i],
                                          state: _optionState(_current, i),
                                          onTap: () => _select(_current, i),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned.fill(
                                  child: IgnorePointer(
                                    ignoring: !_isAnswered(_current),
                                    child: AnimatedSlide(
                                      key: ValueKey(_current),
                                      duration: const Duration(milliseconds: 260),
                                      curve: Curves.easeOutCubic,
                                      offset: _isAnswered(_current) ? Offset.zero : const Offset(0, 1),
                                      child: _isAnswered(_current)
                                          ? _DuoFeedbackSheet(
                                              isCorrect: _selected[_current] == _questions[_current].correctIndex,
                                              question: _questions[_current],
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

  /// 데스크톱 2분할 화면의 한쪽 열 — 문제+보기, 답을 고르면 그 아래에 정답/오답과
  /// "해설 보기" 버튼이 바로 이어서 나온다(왼쪽/오른쪽 모두 독립적으로 풀 수 있다).
  Widget _buildPairColumn(int index, Color color, {double extraFeedbackPadding = 0}) {
    final question = _questions[index];
    final answered = _isAnswered(index);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DuoQuestionBlock(
          question: question,
          color: color,
          questionNumber: index + 1,
          optionCount: question.choices.length,
          showBadges: false,
          optionBuilder: (i) => _OptionTile(
            label: _optionLabels[i],
            text: question.choices[i],
            state: _optionState(index, i),
            onTap: () => _select(index, i),
          ),
        ),
        if (answered) ...[
          // 지문·보기 길이가 반대쪽보다 짧을 때 그 차이만큼 빈 공간을 채워서, 정답/오답 피드백
          // 박스가 좌우 같은 줄에서 시작하도록 한다(문제 자체 안에는 빈틈을 두지 않는다).
          if (extraFeedbackPadding > 0) SizedBox(height: extraFeedbackPadding),
          const SizedBox(height: 10),
          _InlineFeedback(
            isCorrect: _selected[index] == question.correctIndex,
            question: question,
            color: color,
            explanationVisible: _explanationRevealed.contains(index),
            onShowExplanation: () => setState(() => _explanationRevealed.add(index)),
          ),
        ],
      ],
    );
  }

  /// 데스크톱 2분할 화면 하단 고정 내비게이션 — 한 쌍(2문제)씩 이전/다음으로 이동한다.
  Widget _buildPairNavBar(int pairStart, bool isLastPair, Color color) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.glassBorder))),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: pairStart == 0 ? null : () => setState(() => _current = pairStart - 2),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('이전'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: isLastPair ? 2 : 1,
            child: isLastPair
                ? ElevatedButton.icon(
                    onPressed: () => setState(() => _sessionComplete = true),
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('학습 마치기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () => setState(() => _current = pairStart + 2),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('다음'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  _OptionState _optionState(int questionIndex, int choiceIndex) {
    final selected = _selected[questionIndex];
    if (selected == null) return _OptionState.idle;
    final correctIndex = _questions[questionIndex].correctIndex;
    if (choiceIndex == correctIndex) return _OptionState.correct;
    if (choiceIndex == selected) return _OptionState.wrong;
    return _OptionState.disabled;
  }

  /// [text]가 [maxWidth] 안에서 _DuoQuestionBlock과 동일한 스타일로 렌더링될 때의 실제 높이를
  /// 계산한다 — 데스크톱 2분할 화면에서 좌우 지문 줄바꿈 수 차이를 미리 알아내기 위해 쓰인다.
  double _measureStemHeight(String text, double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.7, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth > 0 ? maxWidth : 0);
    return painter.height;
  }

  /// _OptionTile과 동일한 스타일·패딩 기준으로 보기 전체(①~⑤)가 차지할 높이를 추정한다.
  double _measureOptionsHeight(List<String> choices, double columnWidth) {
    const labelWidth = 30.0;
    const verticalPadding = 20.0; // _OptionTile의 위아래 padding 10+10
    var total = 0.0;
    final maxTextWidth = (columnWidth - labelWidth).clamp(0, double.infinity).toDouble();
    for (final choice in choices) {
      final painter = TextPainter(
        text: TextSpan(text: choice, style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500)),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxTextWidth);
      total += painter.height + verticalPadding;
    }
    return total;
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
  final VoidCallback onOpenList;

  const _DuoTopBar({
    required this.current,
    required this.total,
    required this.solved,
    required this.elapsedLabel,
    required this.color,
    required this.onClose,
    required this.onOpenList,
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
              const SizedBox(width: 8),
              IconButton(
                onPressed: onOpenList,
                icon: const Icon(Icons.format_list_numbered_rounded),
                color: AppColors.textMuted,
                tooltip: '문제 목록',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.trackBg,
                  shape: const CircleBorder(),
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

/// 전체 문제 목록 바텀시트 — 몇 번에 어떤 유형(카테고리/세부유형)의 문제가 있는지 한눈에
/// 보여주고, 탭하면 바로 그 문제로 이동한다. 이미 푼 문제는 정답/오답 표시가 함께 보인다.
class _QuestionListSheet extends StatelessWidget {
  final List<Question> questions;
  final List<bool?> results;
  final int current;
  final Color color;
  final ValueChanged<int> onSelect;

  const _QuestionListSheet({
    required this.questions,
    required this.results,
    required this.current,
    required this.color,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.trackBg, borderRadius: BorderRadius.circular(999))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text('전체 문제 목록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const Spacer(),
                  Text('${questions.length}문제', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: questions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final q = questions[index];
                  final result = results[index];
                  final isCurrent = index == current;
                  final label = q.subTopic ?? q.category;
                  return ListTile(
                    onTap: () => onSelect(index),
                    isThreeLine: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    tileColor: isCurrent ? color.withValues(alpha: 0.08) : null,
                    leading: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent ? color : AppColors.trackBg,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isCurrent ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    title: Text(
                      q.stem,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                      ),
                    ),
                    trailing: result == null
                        ? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted)
                        : Icon(
                            result ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: result ? AppColors.correct : AppColors.wrong,
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 문제 블록 — 실제 시험지 느낌으로 흰 배경 + 검은 테두리 박스 안에 문항번호·지문·보기를
/// 색 장식 없이 담백하게 담는다. 유형(카테고리)·기출연도 배지만 박스 위에 작게 보여준다.
class _DuoQuestionBlock extends StatelessWidget {
  final Question question;
  final Color color;
  final int questionNumber;
  final int subTopicPosition;
  final int subTopicTotal;
  final int optionCount;
  final Widget Function(int index) optionBuilder;

  /// 데스크톱 2분할 화면에서는 배지 유무(기출연도 있고 없고 등)에 따라 왼쪽/오른쪽 문항번호
  /// 줄 높이가 달라져 버려서, 그 화면에서는 배지를 아예 숨기고 번호+지문부터 시작한다.
  final bool showBadges;

  const _DuoQuestionBlock({
    required this.question,
    required this.color,
    required this.questionNumber,
    required this.optionCount,
    required this.optionBuilder,
    this.subTopicPosition = 0,
    this.subTopicTotal = 0,
    this.showBadges = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBadges) ...[
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
          const SizedBox(height: 16),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$questionNumber. ', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.7, color: Colors.black)),
            Expanded(
              child: Text(question.stem, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.7, color: Colors.black)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...List.generate(optionCount, (i) => optionBuilder(i)),
      ],
    );
  }
}

/// 답을 고른 뒤 문제 바로 아래에 이어서 보여주는 정답/오답 표시 — 데스크톱 2분할 화면에서
/// 각 열이 독립적으로 갖는다(전체를 덮는 바텀시트가 아니라 그 문제 밑에만 나온다).
/// 해설은 바로 보이지 않고 "해설 보기"를 눌러야 펼쳐진다.
class _InlineFeedback extends StatelessWidget {
  final bool isCorrect;
  final Question question;
  final Color color;
  final bool explanationVisible;
  final VoidCallback onShowExplanation;

  const _InlineFeedback({
    required this.isCorrect,
    required this.question,
    required this.color,
    required this.explanationVisible,
    required this.onShowExplanation,
  });

  @override
  Widget build(BuildContext context) {
    final resultColor = isCorrect ? AppColors.correct : AppColors.wrong;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: resultColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: resultColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: resultColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCorrect ? '정답이에요!' : '아쉬워요, 오답이에요',
                  style: TextStyle(color: resultColor, fontWeight: FontWeight.w900, fontSize: 15.5),
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
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!explanationVisible)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onShowExplanation,
                style: OutlinedButton.styleFrom(
                  foregroundColor: resultColor,
                  side: BorderSide(color: resultColor.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.menu_book_outlined, size: 16),
                label: const Text('해설 보기', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            )
          else ...[
            HighlightedText(
              text: question.summaryExplanation,
              phrases: question.highlightPhrases,
              style: const TextStyle(fontSize: 14.5, height: 1.55, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            ),
            if (question.keyPoints.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: resultColor.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('핵심 포인트', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: resultColor, letterSpacing: 0.4)),
                    const SizedBox(height: 8),
                    ...question.keyPoints.map((k) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('•  ', style: TextStyle(color: resultColor, fontWeight: FontWeight.w800, fontSize: 13.5)),
                              Expanded(
                                child: Text(
                                  k,
                                  style: const TextStyle(fontSize: 13.5, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

enum _OptionState { idle, selected, correct, wrong, disabled }

/// 실제 시험지 보기 한 줄 — 박스·색 장식 없이 "① 텍스트" 형태로 표시한다.
/// 채점 후에는 정답/오답만 최소한의 색(초록/빨강)과 아이콘으로 구분해 학습 피드백을 준다.
class _OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionTile({required this.label, required this.text, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.black;
    Color bgColor = Colors.transparent;
    FontWeight weight = FontWeight.w500;
    Widget? trailing;
    double opacity = 1;

    switch (state) {
      case _OptionState.selected:
        bgColor = const Color(0xFFEDEDED);
        weight = FontWeight.w800;
        break;
      case _OptionState.correct:
        textColor = AppColors.correct;
        weight = FontWeight.w800;
        trailing = const Icon(Icons.check_circle_rounded, color: AppColors.correct, size: 20);
        break;
      case _OptionState.wrong:
        textColor = AppColors.wrong;
        weight = FontWeight.w800;
        trailing = const Icon(Icons.cancel_rounded, color: AppColors.wrong, size: 20);
        break;
      case _OptionState.disabled:
        opacity = 0.5;
        break;
      case _OptionState.idle:
        break;
    }

    return Opacity(
      opacity: opacity,
      child: Material(
        color: bgColor,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 16, height: 1.5, fontWeight: weight, color: textColor)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(text, style: TextStyle(fontSize: 16, height: 1.5, fontWeight: weight, color: textColor)),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 정답 확인 후 화면 하단에서 올라오는 고정 패널(듀오링고 스타일 바텀시트).
/// 해설이 길어도 안의 스크롤 영역만 늘어나고, "다음 유사문제" 버튼은 항상 하단에 고정된다.
/// 해설/핵심개념은 바로 보이지 않고 "해설 보기"를 눌러야 펼쳐진다(스스로 정답 여부를 먼저 생각해보게).
class _DuoFeedbackSheet extends StatefulWidget {
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
  State<_DuoFeedbackSheet> createState() => _DuoFeedbackSheetState();
}

class _DuoFeedbackSheetState extends State<_DuoFeedbackSheet> {
  bool _explanationVisible = false;

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.isCorrect;
    final question = widget.question;
    final onNext = widget.onNext;
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
                    if (!_explanationVisible)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => _explanationVisible = true),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: resultColor,
                            side: BorderSide(color: resultColor.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.menu_book_outlined, size: 18),
                          label: const Text('해설 보기', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      )
                    else ...[
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
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: resultColor.withValues(alpha: 0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '핵심 포인트',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: resultColor, letterSpacing: 0.4),
                              ),
                              const SizedBox(height: 8),
                              ...question.keyPoints.map((k) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('•  ', style: TextStyle(color: resultColor, fontWeight: FontWeight.w800, fontSize: 14)),
                                        Expanded(
                                          child: Text(
                                            k,
                                            style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
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
