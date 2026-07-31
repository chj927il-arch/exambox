import 'package:flutter_test/flutter_test.dart';

import 'package:gamyeong_exam/main.dart';

void main() {
  testWidgets('스플래시 이후 홈 화면 타이틀이 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const GamyeongExamApp());

    // 스플래시 화면의 1초 지연 + 전환 애니메이션이 끝날 때까지 진행시킨다.
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump(const Duration(milliseconds: 500));

    // 상단 고정 헤더 로고 + 홈 화면 학습 시작 배너, 두 곳에 STUDY BOX 타이틀이 표시된다.
    expect(find.textContaining('STUDY BOX'), findsNWidgets(2));
  });
}
