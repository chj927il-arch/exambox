import 'package:flutter/material.dart';
import '../data/sample_questions.dart';
import '../data/user_progress.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../theme/subject_style.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/highlighted_text.dart';

/// 단권화 노트 — 문제풀이 중 북마크(📑) 버튼으로 저장해둔 문제를 모아 보여준다.
/// 오답노트와 달리 정답 여부와 상관없이 "다시 보고 싶어서" 직접 저장한 문제만 모인다.
class CompiledNoteScreen extends StatelessWidget {
  const CompiledNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('단권화 노트')),
      body: ListenableBuilder(
        listenable: UserProgress.instance,
        builder: (context, _) {
          final compiledIds = UserProgress.instance.compiledQuestionIds;
          final questions = sampleQuestions.where((q) => compiledIds.contains(q.id)).toList();

          if (questions.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: '아직 저장한 문제가 없어요',
              description: '문제풀이 중 해설 옆의 📑 버튼을 누르면\n다시 보고 싶은 문제를 여기에 모아둘 수 있어요.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: questions.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Text(
                  '저장한 문제 ${questions.length}개',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                );
              }
              return _CompiledNoteCard(question: questions[i - 1]);
            },
          );
        },
      ),
    );
  }
}

class _CompiledNoteCard extends StatelessWidget {
  final Question question;
  const _CompiledNoteCard({required this.question});

  @override
  Widget build(BuildContext context) {
    final style = subjectStyleOf(question.subjectId);
    final correctText = question.choices[question.correctIndex];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: style.color, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  question.category,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => UserProgress.instance.removeCompiled(question.id),
                icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                tooltip: '단권화 노트에서 제거',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.stem,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1.4, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.correct.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.correct.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.correct),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    correctText,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '해설',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.4),
          ),
          const SizedBox(height: 4),
          HighlightedText(
            text: question.summaryExplanation,
            phrases: question.highlightPhrases,
            style: const TextStyle(fontSize: 14, height: 1.55, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
