import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'marquee_text.dart';

const double kEncourageBarHeight = 25;

/// 응원 문구 바 — 증권 시세 바처럼 계속 흘러간다. 브랜드 네이비 배경 + 흰색 텍스트.
/// 홈 화면 스크롤 콘텐츠 맨 위에 배치돼 스크롤을 내리면 타이틀(상단 고정 영역)과 달리 함께 흘러간다.
class EncourageBar extends StatelessWidget {
  const EncourageBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 데스크톱(넓은 화면)에서는 바가 상대적으로 너무 얇아 보여 높이/글자 크기를 함께 키운다.
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    final height = isDesktop ? 34.0 : kEncourageBarHeight;
    final fontSize = isDesktop ? 17.0 : 14.0;

    return Container(
      width: double.infinity,
      height: height,
      color: AppColors.primary,
      child: MarqueeText(
        text: '네모난 화면 속, 나만의 합격 상자가 열린다',
        style: GoogleFonts.blackHanSans(color: Colors.white, fontSize: fontSize, letterSpacing: -0.1),
        height: height,
        gap: 24,
      ),
    );
  }
}
