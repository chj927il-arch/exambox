import 'package:flutter/material.dart';

/// 상단/영상 오버레이 내비게이션에서 공통으로 쓰는 메뉴 항목 정의.
class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int tabIndex;
  const NavItem(this.icon, this.selectedIcon, this.label, this.tabIndex);
}

const kNavItems = [
  NavItem(Icons.home_outlined, Icons.home, '홈', 0),
  NavItem(Icons.school_outlined, Icons.school, '자격증', 1),
  NavItem(Icons.campaign_outlined, Icons.campaign, '공지사항', 2),
  NavItem(Icons.help_outline_rounded, Icons.help_rounded, 'FAQ', 3),
  NavItem(Icons.person_outline_rounded, Icons.person_rounded, '마이페이지', 4),
];
