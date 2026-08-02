import 'package:flutter/material.dart';
import '../data/board_data.dart';
import '../data/user_reviews.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'write_review_screen.dart';

/// 이용후기 — 내가 작성한 후기(있다면 맨 위) + 기존 후기 목록.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이용후기'), centerTitle: false),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WriteReviewScreen()),
        ),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('후기 작성'),
      ),
      body: ListenableBuilder(
        listenable: UserReviews.instance,
        builder: (context, _) {
          final allReviews = [...UserReviews.instance.submitted, ...reviews];
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
            itemCount: allReviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final r = allReviews[index];
              return GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (r.isNew) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.wrong, borderRadius: BorderRadius.circular(999)),
                            child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < r.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 15,
                              color: AppColors.accentGold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(r.date, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(r.title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(r.body, style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
