import 'package:flutter/material.dart';
import '../data/lecture_data.dart';
import '../theme/ott_theme.dart';
import 'home_screen.dart' show IconLectureCard, LectureCoverCard;
import 'lecture_intro_screen.dart';

/// "부족한 단원만 공부한다_○○" 더보기 — 홈 화면 가로 스크롤 행에 다 담기지 않는
/// 전체 특강 목록을 그리드로 보여준다. 과목별로 title/lectures만 다르게 넘겨 재사용한다.
class LectureGridScreen extends StatelessWidget {
  final String title;
  final List<LectureItem> lectures;
  const LectureGridScreen({
    super.key,
    this.title = '부족한 단원만 공부한다_민법',
    this.lectures = civilLawLectures,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OttColors.bg,
      appBar: AppBar(
        backgroundColor: OttColors.bg,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: lectures.map((item) {
            void onTap(BuildContext context) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LectureIntroScreen(
                      title: item.title,
                      keyPoints: item.keyPoints,
                      subjectId: item.subjectId,
                      subjectName: item.subjectName,
                      category: item.category,
                    ),
                  ),
                );
            if (item.imageAsset != null) {
              return LectureCoverCard(
                imageAsset: item.imageAsset!,
                likeId: item.likeId,
                onTap: onTap,
              );
            }
            return Builder(builder: (context) => IconLectureCard(item: item, onTap: () => onTap(context)));
          }).toList(),
        ),
      ),
    );
  }
}
