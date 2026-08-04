import 'dart:async';
import 'package:flutter/material.dart';
import '../data/mock_exam.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../theme/subject_style.dart';
import '../widgets/highlighted_text.dart';

const _optionLabels = ['①', '②', '③', '④', '⑤'];

/// 실전모의고사 — 실제 시험처럼 제한시간 안에 40문제를 풀고, 정답은 채점 결과
/// 화면에서 한 번에 확인한다(문제풀이 화면과 달리 문제마다 즉시 정답을 보여주지 않는다).
class MockExamScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final int questionCount;
  final Duration timeLimit;

  const MockExamScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    this.questionCount = 40,
    this.timeLimit = const Duration(minutes: 50),
  });

  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen> {
  late final List<Question> _questions;
  late List<int?> _answers;
  int _current = 0;
  bool _submitted = false;
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _questions = buildMockExam(
      widget.subjectId,
      totalCount: widget.questionCount,
    );
    _answers = List<int?>.filled(_questions.length, null);
    _remaining = widget.timeLimit;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining -= const Duration(seconds: 1);
        if (_remaining <= Duration.zero) {
          _remaining = Duration.zero;
          _submit();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _remainingLabel {
    final total = _remaining.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _answeredCount => _answers.where((a) => a != null).length;

  int get _correctCount {
    var count = 0;
    for (var i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctIndex) count++;
    }
    return count;
  }

  void _goTo(int index) {
    setState(() => _current = index);
  }

  /// 데스크톱 폭에서는 두 문제를 좌우로 나란히 보여준다(실제 시험지 펼침 면 느낌).
  bool get _isWide => MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;

  void _next() {
    final step = _isWide ? 2 : 1;
    if (_current + step < _questions.length) {
      setState(() => _current += step);
    }
  }

  void _prev() {
    final step = _isWide ? 2 : 1;
    if (_current - step >= 0) {
      setState(() => _current -= step);
    }
  }

  Future<void> _confirmSubmit() async {
    final unanswered = _questions.length - _answeredCount;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('제출할까요?'),
        content: Text(
          unanswered > 0
              ? '아직 풀지 않은 문제가 $unanswered개 있어요. 그래도 제출할까요?'
              : '모든 문제를 다 풀었어요. 제출할까요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('제출하기'),
          ),
        ],
      ),
    );
    if (confirmed == true) _submit();
  }

  void _submit() {
    _timer?.cancel();
    setState(() => _submitted = true);
  }

  Future<void> _confirmExit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('시험을 중단할까요?'),
        content: const Text('지금 나가면 이번 응시 기록은 저장되지 않아요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('계속 풀기'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.wrong),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('나가기'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final style = subjectStyleOf(widget.subjectId);

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.subjectName} 실전모의고사')),
        body: const Center(child: Text('아직 모의고사를 구성할 문제가 부족합니다.')),
      );
    }

    if (_submitted) {
      return _MockExamResultView(
        subjectName: widget.subjectName,
        color: style.color,
        questions: _questions,
        answers: _answers,
        correctCount: _correctCount,
        elapsed: widget.timeLimit - _remaining,
        onExit: () => Navigator.of(context).pop(),
      );
    }

    final isLowTime = _remaining.inMinutes < 5;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text('${widget.subjectName} 실전모의고사'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _confirmExit,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isLowTime
                      ? AppColors.wrong.withValues(alpha: 0.12)
                      : AppColors.trackBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      size: 16,
                      color: isLowTime
                          ? AppColors.wrong
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _remainingLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isLowTime
                            ? AppColors.wrong
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _AnswerSheetStrip(
              total: _questions.length,
              current: _current,
              answers: _answers,
              color: style.color,
              onTap: _goTo,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '전체 ${_current + 1} / ${_questions.length}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: style.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isWide) _buildQuestionPair() else _buildQuestionColumn(_current),
                  ],
                ),
              ),
            ),
            _BottomNavBar(
              isFirst: _current == 0,
              isLast: _isWide ? (_current ~/ 2) * 2 + 2 >= _questions.length : _current == _questions.length - 1,
              color: style.color,
              onPrev: _prev,
              onNext: _next,
              onSubmit: _confirmSubmit,
            ),
          ],
        ),
      ),
    );
  }

  /// 좁은 화면(모바일)용 — 문제 1개만 세로로 보여준다.
  Widget _buildQuestionColumn(int index) {
    final q = _questions[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${index + 1}. ', style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, height: 1.7, color: Colors.black)),
            Expanded(
              child: Text(q.stem, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, height: 1.7, color: Colors.black)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...List.generate(q.choices.length, (i) {
          final selected = _answers[index] == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _ExamOptionTile(
              label: _optionLabels[i],
              text: q.choices[i],
              selected: selected,
              onTap: () => setState(() => _answers[index] = i),
            ),
          );
        }),
      ],
    );
  }

  /// 넓은 화면(데스크톱)용 — 실제 시험지를 펼친 것처럼 두 문제를 좌우로 나란히 보여준다.
  Widget _buildQuestionPair() {
    final pairStart = (_current ~/ 2) * 2;
    final rightIndex = pairStart + 1 < _questions.length ? pairStart + 1 : null;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildQuestionColumn(pairStart)),
          const SizedBox(width: 24),
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.glassBorder),
          const SizedBox(width: 24),
          Expanded(child: rightIndex != null ? _buildQuestionColumn(rightIndex) : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

/// 상단 답안지 — 문제 번호를 눌러 원하는 문제로 바로 이동할 수 있다(실제 시험지의 답안카드 개념).
class _AnswerSheetStrip extends StatelessWidget {
  final int total;
  final int current;
  final List<int?> answers;
  final Color color;
  final ValueChanged<int> onTap;

  const _AnswerSheetStrip({
    required this.total,
    required this.current,
    required this.answers,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: total,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isCurrent = i == current;
          final isAnswered = answers[i] != null;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              width: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCurrent
                    ? color
                    : (isAnswered
                          ? color.withValues(alpha: 0.14)
                          : Colors.white),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrent
                      ? color
                      : (isAnswered
                            ? color.withValues(alpha: 0.4)
                            : AppColors.glassBorder),
                ),
              ),
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isCurrent
                      ? Colors.white
                      : (isAnswered ? color : AppColors.textMuted),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 실제 시험지 보기 한 줄 — 박스·색 장식 없이 "① 텍스트" 형태로만 표시하고,
/// 선택된 보기만 옅은 회색 배경 + 굵은 글씨로 표시한다.
class _ExamOptionTile extends StatelessWidget {
  final String label;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _ExamOptionTile({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEDEDED) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final Color color;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const _BottomNavBar({
    required this.isFirst,
    required this.isLast,
    required this.color,
    required this.onPrev,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isFirst ? null : onPrev,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('이전'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: isLast ? 2 : 1,
            child: isLast
                ? ElevatedButton.icon(
                    onPressed: onSubmit,
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('제출하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: onNext,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('다음'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 채점 결과 화면 — 점수 요약 + 문제별 정답/오답 리뷰(해설 포함).
class _MockExamResultView extends StatelessWidget {
  final String subjectName;
  final Color color;
  final List<Question> questions;
  final List<int?> answers;
  final int correctCount;
  final Duration elapsed;
  final VoidCallback onExit;

  const _MockExamResultView({
    required this.subjectName,
    required this.color,
    required this.questions,
    required this.answers,
    required this.correctCount,
    required this.elapsed,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final total = questions.length;
    final percent = total == 0 ? 0 : (correctCount / total * 100).round();
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text('$subjectName 모의고사 결과'),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                  ),
                  child: Text(
                    '$percent점',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '$correctCount / $total 문제 정답',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '소요 시간 $minutes분 $seconds초',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            '문제별 채점 결과',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(total, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReviewQuestionTile(
                index: i,
                question: questions[i],
                userAnswer: answers[i],
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onExit,
              child: const Text(
                '돌아가기',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 문제별 채점 결과 카드 — 해설은 바로 보이지 않고 "해설 보기"를 눌러야 펼쳐진다.
class _ReviewQuestionTile extends StatefulWidget {
  final int index;
  final Question question;
  final int? userAnswer;

  const _ReviewQuestionTile({
    required this.index,
    required this.question,
    required this.userAnswer,
  });

  @override
  State<_ReviewQuestionTile> createState() => _ReviewQuestionTileState();
}

class _ReviewQuestionTileState extends State<_ReviewQuestionTile> {
  bool _explanationVisible = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final userAnswer = widget.userAnswer;
    final isCorrect = userAnswer == q.correctIndex;
    final resultColor = isCorrect ? AppColors.correct : AppColors.wrong;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: resultColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: resultColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.index + 1}. ${q.category}',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: resultColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            q.stem,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.4, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            userAnswer == null ? '내 답: 미응답' : '내 답: ${_optionLabels[userAnswer]}. ${q.choices[userAnswer]}',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: resultColor),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 2),
            Text(
              '정답: ${_optionLabels[q.correctIndex]}. ${q.choices[q.correctIndex]}',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.correct),
            ),
          ],
          const SizedBox(height: 10),
          if (!_explanationVisible)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _explanationVisible = true),
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
          else
            HighlightedText(
              text: q.summaryExplanation,
              phrases: q.highlightPhrases,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
