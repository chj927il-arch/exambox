import 'package:flutter/material.dart';
import '../data/lecture_data.dart';
import '../theme/ott_theme.dart';
import 'home_screen.dart' show LectureCoverCard;
import 'lecture_intro_screen.dart';

/// "민법 특강" 더보기 — 홈 화면 가로 스크롤 행에 다 담기지 않는 전체 특강 목록을 그리드로 보여준다.
class LectureGridScreen extends StatelessWidget {
  const LectureGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OttColors.bg,
      appBar: AppBar(
        backgroundColor: OttColors.bg,
        foregroundColor: Colors.white,
        title: const Text('민법 특강'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: civilLawLectures
              .map(
                (item) => LectureCoverCard(
                  imageAsset: item.imageAsset,
                  onTap: (context) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LectureIntroScreen(
                        title: item.title,
                        keyPoints: item.keyPoints,
                        subjectId: item.subjectId,
                        subjectName: item.subjectName,
                        category: item.category,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
