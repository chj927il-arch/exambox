import 'package:flutter/material.dart';
import '../data/ox_quiz_data.dart';
import '../theme/app_theme.dart';
import 'daily_ox_detail_screen.dart';

/// 데일리 OX 퀴즈 목록 — 게시판 형식으로 날짜별 회차를 보여준다.
class DailyOxListScreen extends StatelessWidget {
  const DailyOxListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('데일리 OX 퀴즈'), centerTitle: false),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: dailyOxQuizzes.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final quiz = dailyOxQuizzes[index];
          final isLatest = index == 0;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('OX', style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900, fontSize: 13)),
            ),
            title: Row(
              children: [
                if (isLatest) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.wrong, borderRadius: BorderRadius.circular(999)),
                    child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text('${quiz.date} OX퀴즈', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${quiz.questions.map((q) => q.subjectName).toSet().join('·')} 과목별 1문제씩, 총 ${quiz.questions.length}문제',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DailyOxDetailScreen(quiz: quiz)),
            ),
          );
        },
      ),
    );
  }
}
