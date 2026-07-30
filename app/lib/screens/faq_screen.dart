import 'package:flutter/material.dart';
import '../data/board_data.dart';
import '../theme/app_theme.dart';

/// FAQ — 자주 묻는 질문 (모의 데이터).
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('자주 묻는 질문'), centerTitle: false),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: faqs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.glassBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.white,
                child: ExpansionTile(
                iconColor: AppColors.primary,
                collapsedIconColor: AppColors.textMuted,
                title: Row(
                  children: [
                    const Text('Q', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 15)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(faq.question, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ),
                  ],
                ),
                childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('A', style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w900, fontSize: 15)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(faq.answer, style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ],
              ),
              ),
            ),
          );
        },
      ),
    );
  }
}
