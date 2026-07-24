import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'subject_chapters_screen.dart';

/// 한국사능력검정시험은 심화/기본 두 등급으로 나뉘어 출제되므로,
/// "학습하기" 진입 시 먼저 등급을 선택하게 한 뒤 해당 등급의 챕터 목록으로 이동시킨다.
class KoreanHistoryLevelScreen extends StatelessWidget {
  const KoreanHistoryLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('학습하기'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text(
            '어떤 등급을 학습할까요?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            '등급을 선택하면 시대별 챕터 목록으로 이동해요',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _LevelCard(
            title: '심화',
            subtitle: '1~3급 · 사료·자료 해석형 문제 중심',
            color: const Color(0xFF8C3B3B),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SubjectChaptersScreen(subjectId: 'korean_history', subjectName: '한국사능력검정시험(심화)'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _LevelCard(
            title: '기본',
            subtitle: '4~6급 · 기초 개념·연표 중심 문제',
            color: const Color(0xFF2B6777),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SubjectChaptersScreen(subjectId: 'korean_history_basic', subjectName: '한국사능력검정시험(기본)'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _LevelCard({required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
                  child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$title 등급', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
