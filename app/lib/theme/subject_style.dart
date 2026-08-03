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
  'declaration_of_intent': SubjectStyle(icon: Icons.chat_bubble_outline, color: Color(0xFF2E7D62)), // 그린(의사표시 특강)
  'unfair_act': SubjectStyle(icon: Icons.scale_outlined, color: Color(0xFFB0562C)), // 브라운오렌지(불공정한 법률행위 특강)
  'condition_period': SubjectStyle(icon: Icons.hourglass_bottom_outlined, color: Color(0xFF1F6F8B)), // 블루(조건과 기한 특강)
  'limitation_period': SubjectStyle(icon: Icons.timer_outlined, color: Color(0xFF4A5D8C)), // 인디고(소멸시효 특강)
  'nonperformance': SubjectStyle(icon: Icons.report_gmailerrorred_outlined, color: Color(0xFFA13D3D)), // 레드브라운(채무불이행과 손해배상 특강)
  'contract_termination': SubjectStyle(icon: Icons.link_off_outlined, color: Color(0xFF5C7A5C)), // 세이지그린(계약의 해제·해지 특강)

  // 경영학 특강(회계·마케팅, 표지 이미지 없어 아이콘 카드로 표시)
  'ba_financial_statements': SubjectStyle(icon: Icons.receipt_long_outlined, color: Color(0xFFC98A2B)),
  'ba_inventory': SubjectStyle(icon: Icons.inventory_2_outlined, color: Color(0xFFA8763F)),
  'ba_ppe': SubjectStyle(icon: Icons.factory_outlined, color: Color(0xFF8C6D1F)),
  'ba_stp': SubjectStyle(icon: Icons.pie_chart_outline, color: Color(0xFFDB6B3B)),
  'ba_pricing': SubjectStyle(icon: Icons.sell_outlined, color: Color(0xFFD1495B)),
  'ba_channel': SubjectStyle(icon: Icons.storefront_outlined, color: Color(0xFFE0A93E)),

  // 경제법 특강(표지 이미지 없어 아이콘 카드로 표시)
  'el_dominant': SubjectStyle(icon: Icons.trending_up_outlined, color: Color(0xFF1B3358)),
  'el_leniency': SubjectStyle(icon: Icons.shield_outlined, color: Color(0xFF3C5A80)),
  'el_superior': SubjectStyle(icon: Icons.handshake_outlined, color: Color(0xFF4A6FA5)),
  'el_penalty': SubjectStyle(icon: Icons.payments_outlined, color: Color(0xFF264D73)),
  'el_clause': SubjectStyle(icon: Icons.description_outlined, color: Color(0xFF5C7A99)),
  'el_rpm': SubjectStyle(icon: Icons.price_change_outlined, color: Color(0xFF2E5C8A)),

  // 실전모의고사(표지 이미지 없어 아이콘 카드로 표시)
  'mock_exam_season1': SubjectStyle(icon: Icons.emoji_events_outlined, color: Color(0xFFA8352E)),
  'trap_quiz_season1': SubjectStyle(icon: Icons.warning_amber_rounded, color: Color(0xFF7B2CBF)),
};

const SubjectStyle _fallback = SubjectStyle(icon: Icons.menu_book_outlined, color: Color(0xFF6B7280));

SubjectStyle subjectStyleOf(String subjectId) => _subjectStyles[subjectId] ?? _fallback;
