import 'package:flutter_test/flutter_test.dart';

import 'package:gamyeong_exam/main.dart';

void main() {
  testWidgets('스플래시 이후 홈 화면 타이틀이 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const GamyeongExamApp());

    // 스플래시 화면의 1초 지연 + 전환 애니메이션이 끝날 때까지 진행시킨다.
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump(const Duration(milliseconds: 500));

    // 홈 화면 영상 히어로 오버레이에 STUDY BOX 타이틀이 표시된다.
    // (상단 헤더는 영상 위에서는 투명 상태라 스크롤하기 전까지는 렌더링되지 않는다.)
    expect(find.textContaining('STUDY BOX'), findsOneWidget);
  });
}
