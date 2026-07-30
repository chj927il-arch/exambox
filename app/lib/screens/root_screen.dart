import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/ott_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/marquee_text.dart';
import 'faq_screen.dart';
import 'home_screen.dart';
import 'license_screen.dart';
import 'mypage_screen.dart';
import 'notice_screen.dart';

const double _kEncourageBarHeight = 25;
const double _kTopNavHeight = 46;
const int _kTabCount = 5;

const double _kBottomBarHeight = 52;

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int tabIndex;
  const _NavItem(this.icon, this.selectedIcon, this.label, this.tabIndex);
}

/// 상단 메뉴 — 홈 / 자격증 / 공지사항 / FAQ / 마이페이지 5개. "자격증" 안에서 전문자격사·IT·취업 등으로
/// 분류하고, 각 자격증(예: 가맹거래사) 하위에 시험소개·시험과목·학습하기가 배치된다.
const _navItems = [
  _NavItem(Icons.home_outlined, Icons.home, '홈', 0),
  _NavItem(Icons.school_outlined, Icons.school, '자격증', 1),
  _NavItem(Icons.campaign_outlined, Icons.campaign, '공지사항', 2),
  _NavItem(Icons.help_outline_rounded, Icons.help_rounded, 'FAQ', 3),
  _NavItem(Icons.person_outline_rounded, Icons.person_rounded, '마이페이지', 4),
];

/// 홈 탭 네비게이터의 스택이 루트(홈 화면)인지 추적하는 옵저버.
class _HomeDepthObserver extends NavigatorObserver {
  final ValueChanged<bool> onDepthChanged;
  _HomeDepthObserver({required this.onDepthChanged});

  void _report() => onDepthChanged(navigator?.canPop() != true);

  @override
  void didPush(Route route, Route? previousRoute) => _report();

  @override
  void didPop(Route route, Route? previousRoute) => _report();

  @override
  void didRemove(Route route, Route? previousRoute) => _report();
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _tabIndex = 0;

  // 홈 탭 내에서 다른 화면(공지사항 등)으로 이동하면 하단 바를 숨기기 위해
  // 홈 탭 네비게이터의 스택 깊이를 추적한다.
  bool _homeAtRoot = true;

  final List<GlobalKey<NavigatorState>> _navKeys =
      List.generate(_kTabCount, (_) => GlobalKey<NavigatorState>());

  static const _tabScreens = [
    HomeScreen(),
    LicenseScreen(),
    NoticeScreen(),
    FaqScreen(),
    MyPageScreen(),
  ];

  Widget _buildTabNavigator(int index) {
    return Navigator(
      key: _navKeys[index],
      observers: index == 0 ? [_HomeDepthObserver(onDepthChanged: _setHomeAtRoot)] : const [],
      onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => _tabScreens[index]),
    );
  }

  void _setHomeAtRoot(bool atRoot) {
    if (_homeAtRoot != atRoot) setState(() => _homeAtRoot = atRoot);
  }

  void _onDestinationSelected(int i) {
    if (i == _tabIndex) {
      _navKeys[i].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _tabIndex = i);
    }
  }

  /// 하단 "지금 학습하러가기" 바 — 자격증 탭(가맹거래사 등 자격증 목록)으로 이동시킨다.
  /// 학습하기는 자격증을 먼저 선택해야 들어갈 수 있으므로, 학습화면으로 바로 건너뛰지 않는다.
  void _goToLicenseTab() => _onDestinationSelected(1);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    return isDesktop ? _buildDesktop(context) : _buildMobile(context);
  }

  /// PC/데스크톱(900 이상) — 일반 웹사이트처럼 상단에 가로로 긴 헤더(로고+메뉴) +
  /// 화면 폭에 맞춰 넓게 펼쳐지는 콘텐츠(최대 1200까지, 사이드바 없음).
  Widget _buildDesktop(BuildContext context) {
    final isHome = _tabIndex == 0;
    return Scaffold(
      body: ColoredBox(
        color: isHome ? OttColors.bg : AppColors.trackBg,
        child: SafeArea(
          child: Column(
            children: [
              _DesktopHeader(
                selectedIndex: _tabIndex,
                onSelected: _onDestinationSelected,
                dark: isHome,
              ),
              Expanded(
                child: ColoredBox(
                  color: isHome ? OttColors.bg : AppColors.bgBase,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        children: [
                          if (isHome) const _EncourageBar(),
                          Expanded(
                            child: IndexedStack(
                              index: _tabIndex,
                              children: List.generate(_kTabCount, _buildTabNavigator),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 폰/태블릿(900 미만) — 기존 상단 탭 + 하단 "학습하러가기" 바 레이아웃.
  Widget _buildMobile(BuildContext context) {
    const titleBarHeight = 84.0;
    final isHome = _tabIndex == 0;
    final showEncourage = isHome;
    final showTitle = isHome;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          (showEncourage ? _kEncourageBarHeight : 0) + (showTitle ? titleBarHeight : 0),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showEncourage) const _EncourageBar(),
              if (showTitle)
                AppBar(
                  toolbarHeight: titleBarHeight,
                  backgroundColor: OttColors.bg,
                  title: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'STUDY BOX',
                        style: GoogleFonts.blackHanSans(
                          fontSize: 34,
                          color: OttColors.textPrimary,
                          letterSpacing: 0.5,
                          height: 0.95,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -6),
                        child: const Text(
                          '바쁜 일상, 가장 스마트하게, 가장 콤팩트하게.',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5, color: OttColors.textSecondary),
                        ),
                      ),
                    ],
                    ),
                  ),
                  centerTitle: true,
                ),
            ],
          ),
        ),
      ),
      body: isHome
          ? ColoredBox(
              color: OttColors.bg,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _TopNavBar(selectedIndex: _tabIndex, onSelected: _onDestinationSelected, dark: true),
                    Expanded(
                      child: IndexedStack(
                        index: _tabIndex,
                        children: List.generate(_kTabCount, _buildTabNavigator),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : AppBackground(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _TopNavBar(selectedIndex: _tabIndex, onSelected: _onDestinationSelected, dark: false),
                    Expanded(
                      child: IndexedStack(
                        index: _tabIndex,
                        children: List.generate(_kTabCount, _buildTabNavigator),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar:
          _tabIndex == 0 && _homeAtRoot ? _BottomStudyBar(onTap: _goToLicenseTab) : null,
    );
  }
}

/// 데스크톱 전용 상단 헤더 — 일반 웹사이트처럼 화면 폭 전체를 가로지르는 가로형 내비게이션.
/// 로고(왼쪽) + 메뉴(홈/자격증/마이페이지).
class _DesktopHeader extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool dark;
  const _DesktopHeader({
    required this.selectedIndex,
    required this.onSelected,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = dark ? OttColors.bg : AppColors.bgBase;
    final border = dark ? OttColors.border : AppColors.glassBorder.withValues(alpha: 0.8);
    final textPrimary = dark ? OttColors.textPrimary : AppColors.textPrimary;
    final textSecondary = dark ? OttColors.textSecondary : AppColors.textSecondary;
    final accent = dark ? OttColors.accentStart : AppColors.primary;

    return Container(
      width: double.infinity,
      height: 68,
      decoration: BoxDecoration(color: bg, border: Border(bottom: BorderSide(color: border))),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'STUDY BOX',
                  style: GoogleFonts.blackHanSans(fontSize: 22, color: textPrimary, letterSpacing: 0.5),
                ),
                const SizedBox(width: 44),
                ..._navItems.map((item) {
                  final selected = item.tabIndex == selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 32),
                    child: InkWell(
                      onTap: () => onSelected(item.tabIndex),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          color: selected ? accent : textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 상단 탭 메뉴 — 타이틀/응원바로 아래, 배너 바로 위에 고정된다.
class _TopNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool dark;
  const _TopNavBar({required this.selectedIndex, required this.onSelected, required this.dark});

  @override
  Widget build(BuildContext context) {
    final bg = dark ? OttColors.bg : AppColors.bgBase;
    final border = dark ? OttColors.border : AppColors.glassBorder.withValues(alpha: 0.8);
    final accent = dark ? OttColors.accentStart : AppColors.primary;
    final muted = dark ? OttColors.textMuted : AppColors.textMuted;

    return Container(
      height: _kTopNavHeight,
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: List.generate(_navItems.length, (i) {
          final item = _navItems[i];
          final selected = item.tabIndex == selectedIndex;
          final color = selected ? accent : muted;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(item.tabIndex),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(selected ? item.selectedIcon : item.icon, size: 17, color: color),
                    const SizedBox(height: 1),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      height: 2.5,
                      width: 28,
                      decoration: BoxDecoration(
                        color: selected ? accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 상단 타이틀 위에 표시되는 얇은 응원 문구 바 — 증권 시세바처럼 계속 흘러간다.
/// 브랜드 네이비 배경 + 흰색 텍스트. 화면 폭 끝까지 채우되, 높이는 얇게 줄였다.
class _EncourageBar extends StatelessWidget {
  const _EncourageBar();

  @override
  Widget build(BuildContext context) {
    // 데스크톱(넓은 화면)에서는 바가 상대적으로 너무 얇아 보여 높이/글자 크기를 함께 키운다.
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    final height = isDesktop ? 34.0 : _kEncourageBarHeight;
    final fontSize = isDesktop ? 17.0 : 14.0;

    return Container(
      width: double.infinity,
      height: height,
      color: AppColors.primary,
      child: MarqueeText(
        text: '스터디박스를 켜는 순간 합격이 가까워집니다.',
        style: GoogleFonts.blackHanSans(color: Colors.white, fontSize: fontSize, letterSpacing: -0.1),
        height: height,
        gap: 24,
      ),
    );
  }
}

/// 하단 바 — 버튼 없이, 바 전체가 "지금 학습하러가기" 한 줄짜리 탭 영역.
/// 파랑·보라 그라데이션 배경 위에 은은하게 깜빡이는(pulse) 효과를 줘서 눈에 띄게 한다.
class _BottomStudyBar extends StatefulWidget {
  final VoidCallback onTap;
  const _BottomStudyBar({required this.onTap});

  @override
  State<_BottomStudyBar> createState() => _BottomStudyBarState();
}

class _BottomStudyBarState extends State<_BottomStudyBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color.lerp(const Color(0xFF3B5BFF), const Color(0xFF7B3FF2), t)!,
                Color.lerp(const Color(0xFF7B3FF2), const Color(0xFF3B5BFF), t)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B3FF2).withValues(alpha: 0.35 + 0.35 * t),
                blurRadius: 10 + 6 * t,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: SizedBox(
            height: _kBottomBarHeight,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 23),
                const SizedBox(width: 8),
                Text(
                  '지금 학습하러가기',
                  style: GoogleFonts.blackHanSans(
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
