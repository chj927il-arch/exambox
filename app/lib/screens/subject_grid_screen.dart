import 'package:flutter/material.dart';
import '../models/exam_subject.dart';
import '../theme/ott_theme.dart';
import 'home_screen.dart' show SubjectPosterCard;

/// "과목별 학습" 더보기 — 과목 카드 전체를 그리드로 보여준다.
class SubjectGridScreen extends StatelessWidget {
  const SubjectGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OttColors.bg,
      appBar: AppBar(
        backgroundColor: OttColors.bg,
        foregroundColor: Colors.white,
        title: const Text('과목별 학습'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: examSubjects.map((subject) => SubjectPosterCard(subject: subject)).toList(),
        ),
      ),
    );
  }
}
