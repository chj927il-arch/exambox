import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/comments_store.dart';
import 'data/likes_store.dart';
import 'firebase_options.dart';
import 'screens/root_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  // 폰트가 늦게 로드되면 마키(ticker) 위젯들이 초기 측정 이후 폭이 달라져
  // 텍스트가 겹쳐 보이는 문제가 있어, 첫 프레임 전에 폰트를 미리 받아둔다.
  WidgetsFlutterBinding.ensureInitialized();
  // 실제로 쓰는 폰트를 한 번 참조해야 로딩이 트리거된다.
  GoogleFonts.blackHanSans();
  GoogleFonts.ibmPlexSansKr();
  await GoogleFonts.pendingFonts();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 좋아요·댓글을 기기별로 구분하기 위한 익명 로그인 — 회원가입/로그인 UI는 아직 없지만,
  // Firestore 문서에 "누가" 남겼는지 기록하려면 최소한의 uid가 필요하다.
  await LikesStore.instance.init();
  await CommentsStore.instance.init();
  runApp(const GamyeongExamApp());
}

class GamyeongExamApp extends StatelessWidget {
  const GamyeongExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExamBox',
      theme: AppTheme.light(),
      home: const RootScreen(),
      // 폰/태블릿 폭에서는 앱처럼 보이도록 폭을 제한한다. 데스크톱(900 이상)에서는
      // RootScreen이 사이드 내비게이션 + 중앙 정렬 콘텐츠로 자체 레이아웃을 담당하므로
      // 여기서 폭을 제한하지 않고 그대로 통과시킨다.
      builder: (context, child) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        if (screenWidth >= kDesktopBreakpoint) {
          return ColoredBox(color: AppColors.trackBg, child: child!);
        }
        final maxWidth = screenWidth >= 700 ? 640.0 : 430.0;
        return ColoredBox(
          color: AppColors.trackBg,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
