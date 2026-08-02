import 'package:flutter_test/flutter_test.dart';

import 'package:gamyeong_exam/main.dart';

void main() {
  testWidgets('앱 시작 시 바로 홈 화면 타이틀이 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const GamyeongExamApp());
    await tester.pump();

    // 상단 고정 헤더 왼쪽에 '홈' 내비게이션이 표시된다.
    expect(find.text('홈'), findsOneWidget);
  });
}
