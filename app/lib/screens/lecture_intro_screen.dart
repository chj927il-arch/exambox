import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'quiz_screen.dart';

/// STUDY BOX 특강 카드 진입 시 보여주는 개념 설명 화면 — 핵심을 개조식 목록으로 요약하고,
/// "문제풀이" 버튼을 누르면 해당 category로 필터링된 QuizScreen으로 이동한다.
class LectureIntroScreen extends StatelessWidget {
  final String title;
  final List<String> keyPoints;
  final String subjectId;
  final String subjectName;
  final String category;

  const LectureIntroScreen({
    super.key,
    required this.title,
    required this.keyPoints,
    required this.subjectId,
    required this.subjectName,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: false),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '핵심 개념',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      children: List.generate(keyPoints.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: i == keyPoints.length - 1 ? 0 : 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: const BoxDecoration(color: AppColors.accentGold, shape: BoxShape.circle),
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  keyPoints[i],
                                  style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(subjectId: subjectId, subjectName: subjectName, category: category),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('문제풀이', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
