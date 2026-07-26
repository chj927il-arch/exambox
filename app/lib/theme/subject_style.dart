import 'package:flutter/material.dart';

class SubjectStyle {
  final IconData icon;
  final Color color;

  const SubjectStyle({required this.icon, required this.color});
}

// 브랜드 네이비 + 차분한 보조색 2가지(딥틸, 앰버골드)로 구성.
const Map<String, SubjectStyle> _subjectStyles = {
  'economic_law': SubjectStyle(icon: Icons.balance_outlined, color: Color(0xFF1B3358)), // 브랜드 네이비
  'civil_law': SubjectStyle(icon: Icons.gavel_outlined, color: Color(0xFF2B6777)), // 딥 틸
  'business_admin': SubjectStyle(icon: Icons.insights_outlined, color: Color(0xFFC98A2B)), // 앰버골드
  'korean_history': SubjectStyle(icon: Icons.temple_buddhist_outlined, color: Color(0xFF8C3B3B)), // 고궁 다홍
  'korean_history_basic': SubjectStyle(icon: Icons.temple_buddhist_outlined, color: Color(0xFF2B6777)), // 딥 틸(기본 등급 구분)
  'agency': SubjectStyle(icon: Icons.handshake_outlined, color: Color(0xFF6B4F9E)), // 퍼플(대리행위 특강)
};

const SubjectStyle _fallback = SubjectStyle(icon: Icons.menu_book_outlined, color: Color(0xFF6B7280));

SubjectStyle subjectStyleOf(String subjectId) => _subjectStyles[subjectId] ?? _fallback;
