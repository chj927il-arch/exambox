import 'package:flutter/material.dart';
import '../data/board_data.dart';
import '../data/user_reviews.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

/// 수강후기 작성 화면 — 별점 + 제목 + 내용을 입력받아 UserReviews(메모리 저장소)에 추가한다.
class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String get _todayLabel {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}.$m.$d';
  }

  void _submit() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')),
      );
      return;
    }
    UserReviews.instance.add(
      ReviewItem(date: _todayLabel, title: title, body: body, rating: _rating, isNew: true),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('소중한 후기 감사합니다!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('수강후기 작성'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text('별점', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return IconButton(
                onPressed: () => setState(() => _rating = i + 1),
                icon: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppColors.accentGold,
                  size: 30,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          const Text('제목', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: TextField(
              controller: _titleController,
              maxLength: 40,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '한 줄로 후기를 요약해주세요',
                counterText: '',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('내용', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: TextField(
              controller: _bodyController,
              maxLines: 6,
              maxLength: 500,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '어떤 점이 도움이 되었는지 자유롭게 남겨주세요',
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _submit,
              child: const Text('후기 등록하기', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
