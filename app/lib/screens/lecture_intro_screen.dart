import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

/// STUDY BOX 특강 카드 진입 시 보여주는 개념 설명 화면 — 실제 노트에 손글씨로 필기한 것
/// 같은 스타일(줄노트 배경 + 손글씨 폰트 + 형광펜 하이라이트)로 핵심 개념을 보여준다.
/// "문제풀이" 버튼을 누르면 해당 category로 필터링된 QuizScreen으로 이동한다.
class LectureIntroScreen extends StatelessWidget {
  final String title;
  final List<String> keyPoints;
  final String subjectId;
  final String subjectName;
  final String category;
  final String? subTopic;

  const LectureIntroScreen({
    super.key,
    required this.title,
    required this.keyPoints,
    required this.subjectId,
    required this.subjectName,
    required this.category,
    this.subTopic,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _NotebookColors.paper,
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
        backgroundColor: _NotebookColors.paper,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: _NotebookColors.paper),
                child: CustomPaint(
                  painter: _NotebookLinePainter(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(36, 20, 20, 28),
                    children: [
                      _NotebookHeading(text: title),
                      const SizedBox(height: 4),
                      Text(
                        '- 핵심 개념 정리 -',
                        style: GoogleFonts.gaegu(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _NotebookColors.penBlue.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(keyPoints.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${i + 1}. ',
                                style: GoogleFonts.gaegu(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _NotebookColors.penRed,
                                ),
                              ),
                              Expanded(child: _HighlightedNote(keyPoints[i])),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: _NotebookColors.paper,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(subjectId: subjectId, subjectName: subjectName, category: category, subTopic: subTopic),
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

class _NotebookColors {
  _NotebookColors._();
  static const paper = Color(0xFFFFFDF5);
  static const ruleLine = Color(0xFFCFE0F0);
  static const marginLine = Color(0xFFE9AFAF);
  static const penBlue = Color(0xFF1F3B73);
  static const penRed = Color(0xFFC0392B);
  static const marker = Color(0xFFFFF07A);
}

/// 줄노트 배경 — 가로 줄과 왼쪽 여백선(빨간 세로선)을 그린다.
class _NotebookLinePainter extends CustomPainter {
  static const double lineGap = 34;
  static const double marginX = 26;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = _NotebookColors.ruleLine
      ..strokeWidth = 1;
    for (double y = 56; y < size.height; y += lineGap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    final marginPaint = Paint()
      ..color = _NotebookColors.marginLine
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(marginX, 0), Offset(marginX, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant _NotebookLinePainter oldDelegate) => false;
}

/// 손글씨 폰트의 큰 제목 — 밑에 손으로 그은 듯한 밑줄을 함께 그린다.
class _NotebookHeading extends StatelessWidget {
  final String text;
  const _NotebookHeading({required this.text});

  static final TextStyle _style = GoogleFonts.gaegu(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: _NotebookColors.penBlue,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: _style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout(maxWidth: constraints.maxWidth);
        final underlineWidth = painter.width;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: _style),
            const SizedBox(height: 2),
            CustomPaint(
              size: Size(underlineWidth, 8),
              painter: _SquigglePainter(),
            ),
          ],
        );
      },
    );
  }
}

class _SquigglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _NotebookColors.penRed.withValues(alpha: 0.8)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(0, 4);
    const step = 10.0;
    for (double x = 0; x < size.width; x += step) {
      path.quadraticBezierTo(x + step / 2, x % (step * 2) == 0 ? 0 : 8, x + step, 4);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SquigglePainter oldDelegate) => false;
}

/// keyPoints 문자열 안의 `**강조**` 구간을 형광펜(마커)으로 칠한 것처럼 렌더링한다.
/// (예: '민법 **제103조** — ...' → "제103조"만 노란 마커 강조 표시)
class _HighlightedNote extends StatelessWidget {
  final String text;
  const _HighlightedNote(this.text);

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.gaegu(
      fontSize: 20,
      height: 1.45,
      color: _NotebookColors.penBlue,
      fontWeight: FontWeight.w700,
    );
    final highlightTextStyle = GoogleFonts.gaegu(
      fontSize: 20,
      height: 1.1,
      color: _NotebookColors.penBlue,
      fontWeight: FontWeight.w700,
    );

    final pattern = RegExp(r'\*\*(.+?)\*\*');
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start), style: baseStyle));
      }
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Transform.rotate(
          angle: -0.015,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: _NotebookColors.marker.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(match.group(1)!, style: highlightTextStyle),
          ),
        ),
      ));
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
    }

    return RichText(text: TextSpan(children: spans));
  }
}
