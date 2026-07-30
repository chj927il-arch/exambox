import 'package:flutter/material.dart';

/// 홈 화면(OTT 스타일 개편) 전용 다크 팔레트.
/// 자격증/마이페이지 화면은 기존 라이트 브랜드 테마(app_theme.dart)를 그대로 쓰고,
/// 홈 탭이 선택됐을 때만 상단 내비게이션(RootScreen)도 이 팔레트로 전환된다.
class OttColors {
  OttColors._();

  static const bg = Color(0xFF0B0E14);
  static const surface = Color(0xFF141821);
  static const card = Color(0xFF1B212C);
  static const border = Color(0xFF262C38);

  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFAEB4C2);
  static const textMuted = Color(0xFF6E7585);

  // 기존 하단 "학습하러가기" 바와 동일한 브랜드 그라데이션 톤 — CTA/포인트용.
  static const accentStart = Color(0xFF3B5BFF);
  static const accentEnd = Color(0xFF7B3FF2);
  static const accentGold = Color(0xFFE0A93B);
}
