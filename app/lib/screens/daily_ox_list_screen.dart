import 'package:flutter/material.dart';
import '../config/feature_flags.dart';
import '../data/ox_quiz_data.dart';
import '../theme/app_theme.dart';
import 'daily_ox_detail_screen.dart';

/// 자격증 필터에 노출할 순서 — 가맹거래사를 기본값으로 먼저 보여준다.
const _certFilters = [
  ('franchise_broker', '가맹거래사'),
  if (kKoreanHistoryEnabled) ('korean_history', '한국사능력검정'),
];

/// 데일리 OX 퀴즈 목록 — 자격증(가맹거래사/한국사능력검정)별로 구분해서 보여주는 게시판.
class DailyOxListScreen extends StatefulWidget {
  const DailyOxListScreen({super.key});

  @override
  State<DailyOxListScreen> createState() => _DailyOxListScreenState();
}

class _DailyOxListScreenState extends State<DailyOxListScreen> {
  String _certId = _certFilters.first.$1;

  @override
  Widget build(BuildContext context) {
    final filtered = dailyOxQuizzes.where((q) => q.certId == _certId).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('데일리 OX 퀴즈'), centerTitle: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: _certFilters.map((f) {
                final selected = f.$1 == _certId;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f.$2),
                    selected: selected,
                    onSelected: (_) => setState(() => _certId = f.$1),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.trackBg,
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('아직 등록된 회차가 없습니다.', style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final quiz = filtered[index];
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
                            '${quiz.questions.map((q) => q.subjectName).toSet().join('·')} 과목별 문제, 총 ${quiz.questions.length}문제',
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
          ),
        ],
      ),
    );
  }
}
