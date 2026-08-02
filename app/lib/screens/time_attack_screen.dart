import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/sample_questions.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';

const _optionLabels = ['A', 'B', 'C', 'D', 'E'];
const _kTimeAttackSubjects = ['economic_law', 'civil_law', 'business_admin'];
const _kSubjectNames = {'economic_law': '경제법', 'civil_law': '민법', 'business_admin': '경영학'};
const _kTimeAttackDuration = Duration(seconds: 60);
const _kAdvanceDelay = Duration(milliseconds: 450);

/// 타임어택 — 제한시간 1분 동안 경제법·민법·경영학 문제가 뒤섞여 계속 나오고,
/// 그 안에서 최대한 많이 맞히는 킬링타임용 미니게임. 정답 여부만 짧게 보여주고
/// 바로 다음 문제로 넘어가는 빠른 템포가 핵심이라 상세 해설은 보여주지 않는다.
class TimeAttackScreen extends StatefulWidget {
  const TimeAttackScreen({super.key});

  @override
  State<TimeAttackScreen> createState() => _TimeAttackScreenState();
}

class _TimeAttackScreenState extends State<TimeAttackScreen> {
  late List<Question> _pool;
  late Question _current;
  int? _selectedIndex;
  bool _showResult = false;
  int _solved = 0;
  int _correct = 0;
  Duration _remaining = _kTimeAttackDuration;
  Timer? _tickTimer;
  Timer? _advanceTimer;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _pool = sampleQuestions.where((q) => _kTimeAttackSubjects.contains(q.subjectId)).toList();
    _current = _pickQuestion();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining -= const Duration(seconds: 1);
        if (_remaining <= Duration.zero) {
          _remaining = Duration.zero;
          _finish();
        }
      });
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }

  Question _pickQuestion() => _pool[_random.nextInt(_pool.length)];

  void _finish() {
    _tickTimer?.cancel();
    _advanceTimer?.cancel();
    setState(() => _showResult = true);
  }

  void _select(int index) {
    if (_selectedIndex != null || _showResult) return;
    final correct = index == _current.correctIndex;
    setState(() {
      _selectedIndex = index;
      _solved++;
      if (correct) _correct++;
    });
    _advanceTimer = Timer(_kAdvanceDelay, () {
      if (!mounted || _showResult) return;
      setState(() {
        _current = _pickQuestion();
        _selectedIndex = null;
      });
    });
  }

  void _restart() {
    setState(() {
      _pool = sampleQuestions.where((q) => _kTimeAttackSubjects.contains(q.subjectId)).toList();
      _current = _pickQuestion();
      _selectedIndex = null;
      _showResult = false;
      _solved = 0;
      _correct = 0;
      _remaining = _kTimeAttackDuration;
    });
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining -= const Duration(seconds: 1);
        if (_remaining <= Duration.zero) {
          _remaining = Duration.zero;
          _finish();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE0533D);

    if (_showResult) {
      return Scaffold(
        backgroundColor: AppColors.bgBase,
        appBar: AppBar(title: const Text('타임어택 결과'), centerTitle: false),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [accent, Color(0xFFEB8A6E)]),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 46),
                ),
                const SizedBox(height: 20),
                Text('$_correct문제 정답!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(
                  '총 $_solved문제 도전 · 정답률 ${_solved == 0 ? 0 : (_correct / _solved * 100).round()}%',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: _restart,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('다시 도전', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: const BorderSide(color: accent, width: 1.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('나가기', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isLowTime = _remaining.inSeconds <= 10;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: const Text('타임어택'),
        centerTitle: false,
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isLowTime ? AppColors.wrong.withValues(alpha: 0.12) : accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_rounded, size: 18, color: isLowTime ? AppColors.wrong : accent),
                    const SizedBox(width: 4),
                    Text(
                      '${_remaining.inSeconds}초',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isLowTime ? AppColors.wrong : accent),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  Text('$_solved문제 도전 중', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const Spacer(),
                  Text('정답 $_correct개', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: accent)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(999)),
                      child: Text(
                        _kSubjectNames[_current.subjectId] ?? _current.subjectId,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _current.stem,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.45, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 18),
                    ...List.generate(_current.choices.length, (i) {
                      final isSelected = _selectedIndex == i;
                      final isCorrectChoice = i == _current.correctIndex;
                      Color borderColor = AppColors.glassBorder;
                      Color fillColor = Colors.white;
                      if (_selectedIndex != null) {
                        if (isCorrectChoice) {
                          borderColor = AppColors.correct;
                          fillColor = AppColors.correct.withValues(alpha: 0.12);
                        } else if (isSelected) {
                          borderColor = AppColors.wrong;
                          fillColor = AppColors.wrong.withValues(alpha: 0.12);
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: fillColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor, width: _selectedIndex != null && (isSelected || isCorrectChoice) ? 1.6 : 1),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _select(i),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(color: AppColors.trackBg, borderRadius: BorderRadius.circular(9)),
                                      child: Text(_optionLabels[i], style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800, fontSize: 14)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(_current.choices[i], style: const TextStyle(fontSize: 15.5, height: 1.35, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
