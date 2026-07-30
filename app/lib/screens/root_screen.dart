import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/ott_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/nav_items.dart';
import 'faq_screen.dart';
import 'home_screen.dart';
import 'license_screen.dart';
import 'mypage_screen.dart';
import 'notice_screen.dart';

const double _kTopNavHeight = 46;
const int _kTabCount = 5;

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _tabIndex = 0;
  bool _homeHeaderSolid = false;

  bool _onHomeScrollNotification(ScrollNotification notification) {
    if (_tabIndex != 0) return false;
    final solid = notification.metrics.pixels > 220;
    if (solid != _homeHeaderSolid) {
      setState(() => _homeHeaderSolid = solid);
    }
    return false;
  }

  final List<GlobalKey<NavigatorState>> _navKeys =
      List.generate(_kTabCount, (_) => GlobalKey<NavigatorState>());

  List<Widget> get _tabScreens => [
        HomeScreen(navSelectedIndex: _tabIndex, onNavSelected: _onDestinationSelected),
        const LicenseScreen(),
        const NoticeScreen(),
        const FaqScreen(),
        const MyPageScreen(),
      ];

  Widget _buildTabNavigator(int index) {
    return Navigator(
      key: _navKeys[index],
      onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => _tabScreens[index]),
    );
  }

  void _onDestinationSelected(int i) {
    if (i == _tabIndex) {
      _navKeys[i].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _tabIndex = i);
    }
  }

  /// 모바일 상단 삼선 메뉴 — 회원가입/로그인/마이페이지를 바텀시트로 보여준다.
  void _showMobileMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _tabIndex == 0 ? OttColors.card : AppColors.bgBase,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        final dark = _tabIndex == 0;
        final textColor = dark ? OttColors.textPrimary : AppColors.textPrimary;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                title: Text('회원가입', style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('회원가입 기능은 준비 중이에요.')));
                },
              ),
              ListTile(
                title: Text('로그인', style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('로그인 기능은 준비 중이에요.')));
                },
              ),
              ListTile(
                title: Text('마이페이지', style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _onDestinationSelected(4);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    return isDesktop ? _buildDesktop(context) : _buildMobile(context);
  }

  /// PC/데스크톱(900 이상) — 일반 웹사이트처럼 상단에 가로로 긴 헤더(로고+메뉴) +
  /// 화면 폭에 맞춰 넓게 펼쳐지는 콘텐츠(최대 1200까지, 사이드바 없음).
  /// 홈 탭에서는 헤더가 상단 영상 위에 투명하게 떠 있다가(쿠팡플레이 스타일), 영상을 지나
  /// 스크롤하면 불투명 배경으로 전환된다.
  Widget _buildDesktop(BuildContext context) {
    final isHome = _tabIndex == 0;
    final overlay = isHome && !_homeHeaderSolid;

    return Scaffold(
      body: ColoredBox(
        color: isHome ? OttColors.bg : AppColors.trackBg,
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                top: isHome ? 0 : 68,
                child: ColoredBox(
                  color: isHome ? OttColors.bg : AppColors.bgBase,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _onHomeScrollNotification,
                        child: IndexedStack(
                          index: _tabIndex,
                          children: List.generate(_kTabCount, _buildTabNavigator),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (!overlay)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 68,
                  child: _DesktopHeader(
                    selectedIndex: _tabIndex,
                    onSelected: _onDestinationSelected,
                    dark: isHome,
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
    final showTitle = isHome;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(showTitle ? titleBarHeight : 0),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    _TopNavBar(
                      selectedIndex: _tabIndex,
                      onSelected: _onDestinationSelected,
                      onMenuTap: () => _showMobileMoreMenu(context),
                      dark: true,
                    ),
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
                    _TopNavBar(
                      selectedIndex: _tabIndex,
                      onSelected: _onDestinationSelected,
                      onMenuTap: () => _showMobileMoreMenu(context),
                      dark: false,
                    ),
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

    Widget navText(String label, {required bool selected, required VoidCallback onTap}) {
      return InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? accent : textSecondary,
          ),
        ),
      );
    }

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
                const SizedBox(width: 32),
                // 마이페이지는 왼쪽 탭이 아니라 오른쪽 회원가입/로그인 옆으로 이동.
                ...kNavItems.where((item) => item.label != '마이페이지').map((item) {
                  final selected = item.tabIndex == selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 32),
                    child: navText(item.label, selected: selected, onTap: () => onSelected(item.tabIndex)),
                  );
                }),
                const Spacer(),
                navText(
                  '회원가입',
                  selected: false,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('회원가입 기능은 준비 중이에요.')),
                  ),
                ),
                const SizedBox(width: 20),
                navText(
                  '로그인',
                  selected: false,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인 기능은 준비 중이에요.')),
                  ),
                ),
                const SizedBox(width: 20),
                Builder(builder: (context) {
                  final myPage = kNavItems.firstWhere((item) => item.label == '마이페이지');
                  final selected = myPage.tabIndex == selectedIndex;
                  return navText(myPage.label, selected: selected, onTap: () => onSelected(myPage.tabIndex));
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
/// 모바일 상단 탭 — 홈/자격증/공지사항/FAQ만 아이콘 탭으로 보여주고, 마이페이지·회원가입·
/// 로그인은 오른쪽 삼선 메뉴(onMenuTap)를 눌러야 나오는 목록으로 옮겼다.
class _TopNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onMenuTap;
  final bool dark;
  const _TopNavBar({
    required this.selectedIndex,
    required this.onSelected,
    required this.onMenuTap,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = dark ? OttColors.bg : AppColors.bgBase;
    final border = dark ? OttColors.border : AppColors.glassBorder.withValues(alpha: 0.8);
    final accent = dark ? OttColors.accentStart : AppColors.primary;
    final muted = dark ? OttColors.textMuted : AppColors.textMuted;
    final tabItems = kNavItems.where((item) => item.label != '마이페이지').toList();

    return Container(
      height: _kTopNavHeight,
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          ...tabItems.map((item) {
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
          SizedBox(
            width: 52,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onMenuTap,
                child: Icon(Icons.menu_rounded, size: 22, color: muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

