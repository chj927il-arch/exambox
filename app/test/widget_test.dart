import 'package:flutter_test/flutter_test.dart';

import 'package:gamyeong_exam/main.dart';

void main() {
  testWidgets('앱 시작 시 바로 홈 화면 타이틀이 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const GamyeongExamApp());
    await tester.pump();

    // 상단 고정 헤더 로고에 STUDY BOX 타이틀이 표시된다.
    expect(find.textContaining('STUDY BOX'), findsOneWidget);
  });
}
