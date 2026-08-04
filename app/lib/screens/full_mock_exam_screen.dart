import 'dart:async';
import 'package:flutter/material.dart';
import '../data/mock_exam.dart';
import '../models/exam_subject.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../theme/subject_style.dart';
import '../widgets/highlighted_text.dart';

const _optionLabels = ['①', '②', '③', '④', '⑤'];
const _kQuestionsPerSubject = 40;
const _kFailingScore = 40; // 과락 기준(과목별)
const _kPassingAverage = 60; // 합격 기준(3과목 평균)

/// 한 과목 분량(40문제)을 하나의 구간으로 묶어 전체 120문제 흐름 안에서
/// "지금 몇 과목, 몇 번째 문제"를 알 수 있게 한다.
class _ExamSection {
  final String subjectId;
  final String subjectName;
  final List<Question> questions;
  const _ExamSection({
    required this.subjectId,
    required this.subjectName,
    required this.questions,
  });
}

/// 실전모의고사 시즌1 — 3과목(경제법·민법·경영학) x 40문제 = 120문제를
/// 실제 시험과 동일하게 120분 안에 이어서 풀고, 과목별 과락(40점 미만)과
/// 3과목 평균 합격선(60점)을 함께 판정한다.
class FullMockExamScreen extends StatefulWidget {
  final Duration timeLimit;

  const FullMockExamScreen({
    super.key,
    this.timeLimit = const Duration(minutes: 120),
  });

  @override
  State<FullMockExamScreen> createState() => _FullMockExamScreenState();
}

class _FullMockExamScreenState extends State<FullMockExamScreen> {
  late final List<_ExamSection> _sections;
  late final List<Question> _questions;
  late List<int?> _answers;
  int _current = 0;
  bool _submitted = false;
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sections = examSubjects
        .map(
          (s) => _ExamSection(
            subjectId: s.id,
            subjectName: s.name,
            questions: buildMockExam(s.id, totalCount: _kQuestionsPerSubject),
          ),
        )
        .toList();
    _questions = _sections.expand((s) => s.questions).toList();
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
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0)
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int get _answeredCount => _answers.where((a) => a != null).length;

  /// 현재 문제가 속한 과목 구간(section) index.
  int get _currentSectionIndex {
    var offset = 0;
    for (var i = 0; i < _sections.length; i++) {
      offset += _sections[i].questions.length;
      if (_current < offset) return i;
    }
    return _sections.length - 1;
  }

  /// 과목 안에서 몇 번째 문제인지 — 실제 시험지처럼 과목별로 1번부터 다시 번호를 매긴다.
  int get _currentLocalNumber {
    final sectionStart = _sections
        .take(_currentSectionIndex)
        .fold<int>(0, (a, s) => a + s.questions.length);
    return _current - sectionStart + 1;
  }

  void _select(int index) => setState(() => _answers[_current] = index);
  void _goTo(int index) => setState(() => _current = index);
  void _next() {
    if (_current + 1 < _questions.length) setState(() => _current++);
  }

  void _prev() {
    if (_current > 0) setState(() => _current--);
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
              : '3과목 120문제를 모두 풀었어요. 제출할까요?',
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
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('실전모의고사 시즌1')),
        body: const Center(child: Text('아직 모의고사를 구성할 문제가 부족합니다.')),
      );
    }

    if (_submitted) {
      return _FullMockExamResultView(
        sections: _sections,
        questions: _questions,
        answers: _answers,
        elapsed: widget.timeLimit - _remaining,
        onExit: () => Navigator.of(context).pop(),
      );
    }

    final sectionIndex = _currentSectionIndex;
    final section = _sections[sectionIndex];
    final style = subjectStyleOf(section.subjectId);
    final question = _questions[_current];
    final isLowTime = _remaining.inMinutes < 10;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text('실전모의고사 · ${section.subjectName}'),
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
            _SectionTabs(
              sections: _sections,
              currentSectionIndex: sectionIndex,
              currentGlobalIndex: _current,
              onJumpToSection: _goTo,
            ),
            _AnswerSheetStrip(
              section: section,
              globalOffset: _sections
                  .take(sectionIndex)
                  .fold<int>(0, (a, s) => a + s.questions.length),
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
                    // 실제 시험지 느낌 — 박스 없이 흰 배경 위에 문항 번호와 지문, ①~⑤ 보기를
                    // 색 장식 없이 담백하게 배치한다(줄바꿈 시 지문 첫 글자 위치로 정렬).
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_currentLocalNumber. ',
                          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, height: 1.7, color: Colors.black),
                        ),
                        Expanded(
                          child: Text(
                            question.stem,
                            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, height: 1.7, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(question.choices.length, (i) {
                      final selected = _answers[_current] == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _ExamOptionTile(
                          label: _optionLabels[i],
                          text: question.choices[i],
                          selected: selected,
                          onTap: () => _select(i),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            _BottomNavBar(
              isFirst: _current == 0,
              isLast: _current == _questions.length - 1,
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
}

/// 과목 구간 탭 — 지금 어느 과목을 풀고 있는지 보여주고, 탭하면 그 과목 첫 문제로 이동한다.
class _SectionTabs extends StatelessWidget {
  final List<_ExamSection> sections;
  final int currentSectionIndex;
  final int currentGlobalIndex;
  final ValueChanged<int> onJumpToSection;

  const _SectionTabs({
    required this.sections,
    required this.currentSectionIndex,
    required this.currentGlobalIndex,
    required this.onJumpToSection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: List.generate(sections.length, (i) {
          final section = sections[i];
          final style = subjectStyleOf(section.subjectId);
          final isCurrent = i == currentSectionIndex;
          var offset = 0;
          for (var j = 0; j < i; j++) {
            offset += sections[j].questions.length;
          }
          final startIndex = offset;
          return Expanded(
            child: GestureDetector(
              onTap: () => onJumpToSection(startIndex),
              child: Container(
                margin: EdgeInsets.only(
                  right: i == sections.length - 1 ? 0 : 8,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrent ? style.color : AppColors.trackBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  section.subjectName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isCurrent ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _AnswerSheetStrip extends StatelessWidget {
  final _ExamSection section;
  final int globalOffset;
  final int current;
  final List<int?> answers;
  final Color color;
  final ValueChanged<int> onTap;

  const _AnswerSheetStrip({
    required this.section,
    required this.globalOffset,
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
        itemCount: section.questions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, localIndex) {
          final globalIndex = globalOffset + localIndex;
          final isCurrent = globalIndex == current;
          final isAnswered = answers[globalIndex] != null;
          return GestureDetector(
            onTap: () => onTap(globalIndex),
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
                '${localIndex + 1}',
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
/// 선택된 보기만 옅은 회색 배경 + 굵은 글씨로 표시한다(실제 시험지에 표시하듯).
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

class _SubjectResult {
  final _ExamSection section;
  final int correctCount;
  final double score;
  const _SubjectResult({
    required this.section,
    required this.correctCount,
    required this.score,
  });

  bool get isFailing => score < _kFailingScore;
}

/// 채점 결과 — 과목별 점수/과락 여부 + 3과목 평균 + 최종 합격/불합격 판정, 문제별 리뷰.
class _FullMockExamResultView extends StatelessWidget {
  final List<_ExamSection> sections;
  final List<Question> questions;
  final List<int?> answers;
  final Duration elapsed;
  final VoidCallback onExit;

  const _FullMockExamResultView({
    required this.sections,
    required this.questions,
    required this.answers,
    required this.elapsed,
    required this.onExit,
  });

  List<_SubjectResult> get _results {
    final results = <_SubjectResult>[];
    var offset = 0;
    for (final section in sections) {
      var correct = 0;
      for (var i = 0; i < section.questions.length; i++) {
        final globalIndex = offset + i;
        if (answers[globalIndex] == section.questions[i].correctIndex)
          correct++;
      }
      final score = section.questions.isEmpty
          ? 0.0
          : correct / section.questions.length * 100;
      results.add(
        _SubjectResult(section: section, correctCount: correct, score: score),
      );
      offset += section.questions.length;
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final average = results.isEmpty
        ? 0.0
        : results.map((r) => r.score).reduce((a, b) => a + b) / results.length;
    final hasFailingSubject = results.any((r) => r.isFailing);
    final isPass = !hasFailingSubject && average >= _kPassingAverage;
    final totalCorrect = results.fold<int>(0, (a, r) => a + r.correctCount);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    final resultColor = isPass ? AppColors.correct : AppColors.wrong;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: const Text('실전모의고사 시즌1 결과'),
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
                  width: 108,
                  height: 108,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [resultColor, resultColor.withValues(alpha: 0.7)],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isPass ? '합격' : '불합격',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '평균 ${average.toStringAsFixed(1)}점',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '총 $totalCorrect / ${questions.length} 문제 정답',
                  style: const TextStyle(
                    fontSize: 17,
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
                if (hasFailingSubject) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '과락(40점 미만) 과목이 있어 평균과 무관하게 불합격입니다.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.wrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else if (!isPass) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '3과목 평균이 60점 미만이라 불합격입니다.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.wrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '과목별 성적',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...results.map((r) {
            final style = subjectStyleOf(r.section.subjectId);
            final failColor = r.isFailing ? AppColors.wrong : AppColors.correct;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: failColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: style.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(style.icon, color: style.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.section.subjectName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${r.correctCount} / ${r.section.questions.length}문항 정답',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${r.score.toStringAsFixed(1)}점',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: failColor,
                          ),
                        ),
                        if (r.isFailing)
                          const Text(
                            '과락',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.wrong,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          const Text(
            '문제별 채점 결과',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...() {
            final tiles = <Widget>[];
            var offset = 0;
            for (final section in sections) {
              tiles.add(
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    section.subjectName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: subjectStyleOf(section.subjectId).color,
                    ),
                  ),
                ),
              );
              for (var i = 0; i < section.questions.length; i++) {
                final globalIndex = offset + i;
                tiles.add(
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReviewQuestionTile(
                      index: i,
                      question: questions[globalIndex],
                      userAnswer: answers[globalIndex],
                    ),
                  ),
                );
              }
              offset += section.questions.length;
            }
            return tiles;
          }(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: resultColor,
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
