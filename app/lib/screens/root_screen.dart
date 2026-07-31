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

const int _kTabCount = 5;
const double _kHeaderHeight = 68;

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _tabIndex = 0;
  bool _homeHeaderSolid = false;
  static const double _solidThreshold = 220;

  bool _onHomeScrollNotification(ScrollNotification notification) {
    if (_tabIndex != 0) return false;
    // 홈 화면 안에는 가로로 계속 흘러가는 배너/마퀴 위젯(수강후기 롤링 스트립, 상단 프로모션
    // 롤링배너 등)이 여러 개 있고, 이들도 스크롤 알림을 발생시켜 이 리스너까지 올라온다.
    // 세로 스크롤이 아닌 알림(가로 스크롤)은 페이지 스크롤과 무관하니 무시해야 한다.
    if (notification.metrics.axis != Axis.vertical) return false;
    final solid = notification.metrics.pixels > _solidThreshold;
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

  /// PC/모바일 공통 레이아웃 — 홈 탭에서는 영상이 화면 맨 위(가장자리까지)를 채우고,
  /// 그 위에 헤더가 투명하게 떠 있다가(쿠팡플레이 스타일) 영상을 지나 스크롤하면
  /// 불투명 배경으로 전환된다. PC/모바일 차이는 전부 폭 제한(maxWidth)과 헤더 내부
  /// 폰트/패딩 크기뿐 — 구조 자체는 완전히 동일하다.
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    final isHome = _tabIndex == 0;
    final overlay = isHome && !_homeHeaderSolid;
    final maxWidth = isDesktop ? 1200.0 : double.infinity;

    return Scaffold(
      body: ColoredBox(
        color: isHome ? OttColors.bg : AppColors.trackBg,
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                top: isHome ? 0 : _kHeaderHeight,
                child: ColoredBox(
                  color: isHome ? OttColors.bg : AppColors.bgBase,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _onHomeScrollNotification,
                        child: isHome
                            ? IndexedStack(
                                index: _tabIndex,
                                children: List.generate(_kTabCount, _buildTabNavigator),
                              )
                            : AppBackground(
                                child: IndexedStack(
                                  index: _tabIndex,
                                  children: List.generate(_kTabCount, _buildTabNavigator),
                                ),
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
                  height: _kHeaderHeight,
                  child: _SiteHeader(
                    selectedIndex: _tabIndex,
                    onSelected: _onDestinationSelected,
                    dark: isHome,
                    isDesktop: isDesktop,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 상단 헤더 — PC/모바일 공통. 로고 + 홈/마이페이지 + 회원가입/로그인.
/// 자격증/공지사항/FAQ는 영상 히어로 오버레이 메뉴와 동일하게 여기서도 숨긴다
/// (하단 CTA로 가맹거래사 상세로 바로 진입하므로 상단 메뉴에서는 노출하지 않음).
class _SiteHeader extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool dark;
  final bool isDesktop;
  const _SiteHeader({
    required this.selectedIndex,
    required this.onSelected,
    required this.dark,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final bg = dark ? OttColors.bg : AppColors.bgBase;
    final border = dark ? OttColors.border : AppColors.glassBorder.withValues(alpha: 0.8);
    final textPrimary = dark ? OttColors.textPrimary : AppColors.textPrimary;
    final textSecondary = dark ? OttColors.textSecondary : AppColors.textSecondary;
    final accent = dark ? OttColors.accentStart : AppColors.primary;

    final logoSize = isDesktop ? 22.0 : 18.0;
    final navGap = isDesktop ? 32.0 : 16.0;
    final navFontSize = isDesktop ? 14.0 : 12.5;
    final hPad = isDesktop ? 24.0 : 16.0;

    Widget navText(String label, {required bool selected, required VoidCallback onTap}) {
      return InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: navFontSize,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? accent : textSecondary,
          ),
        ),
      );
    }

    final home = kNavItems.firstWhere((item) => item.label == '홈');
    final myPage = kNavItems.firstWhere((item) => item.label == '마이페이지');

    return Container(
      width: double.infinity,
      height: _kHeaderHeight,
      decoration: BoxDecoration(color: bg, border: Border(bottom: BorderSide(color: border))),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Row(
              children: [
                Text(
                  'STUDY BOX',
                  style: GoogleFonts.blackHanSans(fontSize: logoSize, color: textPrimary, letterSpacing: 0.5),
                ),
                SizedBox(width: navGap),
                navText(home.label, selected: home.tabIndex == selectedIndex, onTap: () => onSelected(home.tabIndex)),
                const Spacer(),
                navText(
                  '회원가입',
                  selected: false,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('회원가입 기능은 준비 중이에요.')),
                  ),
                ),
                SizedBox(width: navGap * 0.6),
                navText(
                  '로그인',
                  selected: false,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인 기능은 준비 중이에요.')),
                  ),
                ),
                SizedBox(width: navGap * 0.6),
                navText(myPage.label, selected: myPage.tabIndex == selectedIndex, onTap: () => onSelected(myPage.tabIndex)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
