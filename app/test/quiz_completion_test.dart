import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamyeong_exam/data/sample_questions.dart';
import 'package:gamyeong_exam/data/user_progress.dart';
import 'package:gamyeong_exam/screens/certificate_menu_screen.dart';
import 'package:gamyeong_exam/screens/quiz_screen.dart';
import 'package:gamyeong_exam/screens/study_screen.dart';
import 'package:gamyeong_exam/screens/subject_chapters_screen.dart';
import 'package:gamyeong_exam/theme/app_theme.dart';

void main() {
  // 챕터('구속조건부거래')는 샘플 문제가 1개뿐이라, 한 문제만 풀어도 바로 회차가 끝나
  // 완료 화면(복습하기/끝내기) 로직을 빠르게 검증할 수 있다.
  const subjectId = 'economic_law';
  const category = '구속조건부거래';

  Widget buildApp() {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => const QuizScreen(subjectId: subjectId, subjectName: '경제법', category: category),
        ),
      ),
    );
  }

  /// 완료 화면의 버튼들이 화면 아래로 밀려 테스트 뷰포트(기본 800x600) 밖에 놓이는 것을
  /// 막기 위해 넉넉히 긴 가상 화면으로 키운다.
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> answerCurrentQuestion(WidgetTester tester) async {
    final question = sampleQuestions.firstWhere((q) => q.subjectId == subjectId && q.category == category);
    await tester.tap(find.text(question.choices.first));
    await tester.pump();
    await tester.tap(find.text('다음 유사문제'));
    await tester.pump();
  }

  testWidgets('마지막 문제를 풀면 복습하기/끝내기 버튼이 있는 완료 화면이 뜬다', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(buildApp());
    await answerCurrentQuestion(tester);

    expect(find.text('문제를 다 풀었어요!'), findsOneWidget);
    expect(find.text('복습하기'), findsOneWidget);
    expect(find.text('끝내기'), findsOneWidget);
  });

  testWidgets('복습하기를 누르면 완료 화면이 사라지고 문제를 다시 풀 수 있다', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(buildApp());
    await answerCurrentQuestion(tester);
    expect(find.text('문제를 다 풀었어요!'), findsOneWidget);

    await tester.tap(find.text('복습하기'));
    await tester.pump();

    expect(find.text('문제를 다 풀었어요!'), findsNothing);
    final question = sampleQuestions.firstWhere((q) => q.subjectId == subjectId && q.category == category);
    expect(find.text(question.stem), findsOneWidget);
  });

  testWidgets('문제를 풀면 UserProgress에 학습시간·정답기록이 반영된다', (tester) async {
    useTallViewport(tester);
    final before = UserProgress.instance.totalSolved;
    await tester.pumpWidget(buildApp());
    await answerCurrentQuestion(tester);

    expect(UserProgress.instance.totalSolved, before + 1);
    expect(
      UserProgress.instance.weakestCategories(minAttempts: 1).any((s) => s.category == category),
      isTrue,
    );
  });

  testWidgets('끝내기를 누르면 학습하기 탭의 과목 메뉴로 돌아간다', (tester) async {
    useTallViewport(tester);
    // 홈 화면의 "지금 학습 시작하기" 배너는 인트로 영상으로 교체되며 임시로 제거된 상태라
    // (자격증 탭 진입 지점은 추후 다시 배치 예정), CertificateMenuScreen부터 직접 렌더링해
    // 그 이후 플로우(학습하기 → 과목 → 챕터 → 문제풀이 → 끝내기)를 검증한다.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (_) => const CertificateMenuScreen(certId: 'franchise_broker', certName: '가맹거래사'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CertificateMenuScreen), findsOneWidget);

    await tester.tap(find.descendant(of: find.byType(CertificateMenuScreen), matching: find.text('학습하기')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(StudyScreen), findsOneWidget);

    // 경제법 → 챕터 목록(SubjectChaptersScreen)
    await tester.tap(find.descendant(of: find.byType(StudyScreen), matching: find.text('경제법')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SubjectChaptersScreen), findsOneWidget);

    // 문제가 1개뿐인 챕터로 진입 → QuizScreen. 챕터 목록이 길어 지연 렌더링되므로
    // (뷰포트+캐시 범위 밖 항목은 아직 빌드되지 않음) scrollUntilVisible로 실제 스크롤하며 찾는다.
    final chapterFinder = find.descendant(of: find.byType(SubjectChaptersScreen), matching: find.text(category));
    final scrollableFinder = find.descendant(of: find.byType(SubjectChaptersScreen), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(chapterFinder, 300, scrollable: scrollableFinder);
    await tester.pump();
    await tester.tap(chapterFinder);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(QuizScreen), findsOneWidget);

    await answerCurrentQuestion(tester);
    expect(find.text('끝내기'), findsOneWidget);

    await tester.tap(find.text('끝내기'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(StudyScreen), findsOneWidget);
    expect(find.byType(QuizScreen), findsNothing);
  });
}
