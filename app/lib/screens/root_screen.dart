import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/marquee_text.dart';
import 'home_screen.dart';
import 'license_screen.dart';
import 'mypage_screen.dart';

const double _kEncourageBarHeight = 25;
const double _kTopNavHeight = 46;
const int _kTabCount = 3;

const double _kBottomBarHeight = 52;

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int tabIndex;
  const _NavItem(this.icon, this.selectedIcon, this.label, this.tabIndex);
}

/// 상단 메뉴 — 홈 / 자격증 / 마이페이지 3개. "자격증" 안에서 전문자격사·IT·취업 등으로 분류하고,
/// 각 자격증(예: 가맹거래사) 하위에 시험소개·시험과목·학습하기가 배치된다.
const _navItems = [
  _NavItem(Icons.home_outlined, Icons.home, '홈', 0),
  _NavItem(Icons.school_outlined, Icons.school, '자격증', 1),
  _NavItem(Icons.person_outline_rounded, Icons.person_rounded, '마이페이지', 2),
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
    const titleBarHeight = 84.0;
    final showEncourage = _tabIndex == 0;
    final showTitle = _tabIndex == 0;

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
                  title: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'STUDY BOX',
                        style: GoogleFonts.blackHanSans(
                          fontSize: 34,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                          height: 0.95,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -6),
                        child: const Text(
                          '바쁜 일상, 가장 스마트하게, 가장 콤팩트하게.',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5, color: AppColors.textSecondary),
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
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopNavBar(selectedIndex: _tabIndex, onSelected: _onDestinationSelected),
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

/// 상단 탭 메뉴 — 타이틀/응원바로 아래, 배너 바로 위에 고정된다.
class _TopNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const _TopNavBar({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kTopNavHeight,
      decoration: BoxDecoration(
        color: AppColors.bgBase,
        border: Border(bottom: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.8))),
      ),
      child: Row(
        children: List.generate(_navItems.length, (i) {
          final item = _navItems[i];
          final selected = item.tabIndex == selectedIndex;
          final color = selected ? AppColors.primary : AppColors.textMuted;
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
                        color: selected ? AppColors.primary : Colors.transparent,
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
    return Container(
      width: double.infinity,
      height: _kEncourageBarHeight,
      color: AppColors.primary,
      child: MarqueeText(
        text: '스터디박스를 켜는 순간 합격이 가까워집니다.',
        style: GoogleFonts.blackHanSans(color: Colors.white, fontSize: 14, letterSpacing: -0.1),
        height: _kEncourageBarHeight,
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
