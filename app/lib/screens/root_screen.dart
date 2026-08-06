import 'package:flutter/material.dart';
import '../data/visit_counter.dart';
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

  final List<GlobalKey<NavigatorState>> _navKeys =
      List.generate(_kTabCount, (_) => GlobalKey<NavigatorState>());

  List<Widget> get _tabScreens => [
        const HomeScreen(),
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

  /// PC/모바일 공통 레이아웃 — 상단에 항상 고정 헤더를 두고 그 아래에 탭 콘텐츠를 채운다.
  /// PC/모바일 차이는 전부 폭 제한(maxWidth)과 헤더 내부 폰트/패딩 크기뿐.
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    final isHome = _tabIndex == 0;
    final maxWidth = isDesktop ? 1200.0 : double.infinity;

    return Scaffold(
      body: ColoredBox(
        color: isHome ? OttColors.bg : AppColors.trackBg,
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                top: _kHeaderHeight,
                child: ColoredBox(
                  color: isHome ? OttColors.bg : AppColors.bgBase,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
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

/// 상단 헤더 — PC/모바일 공통. 로고 + 홈.
/// 자격증/공지사항/FAQ는 영상 히어로 오버레이 메뉴와 동일하게 여기서도 숨긴다
/// (하단 CTA로 가맹거래사 상세로 바로 진입하므로 상단 메뉴에서는 노출하지 않음).
/// 회원가입/로그인/마이페이지는 일단 숨기고, 그 자리에 오늘/누적 방문자 수를 표시한다.
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
    final textSecondary = dark ? OttColors.textSecondary : AppColors.textSecondary;
    final accent = dark ? OttColors.accentStart : AppColors.primary;

    final navFontSize = isDesktop ? 16.0 : 14.0;
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
                navText(home.label, selected: home.tabIndex == selectedIndex, onTap: () => onSelected(home.tabIndex)),
                const Spacer(),
                _VisitCountDisplay(textColor: textSecondary, accent: accent, isDesktop: isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 상단 헤더 우측 — 회원가입/로그인/마이페이지 대신 임시로 넣은 오늘/누적 방문자 수 표시.
/// 값을 아직 못 불러왔으면(초기 로딩 중) 아무것도 보여주지 않는다.
class _VisitCountDisplay extends StatelessWidget {
  final Color textColor;
  final Color accent;
  final bool isDesktop;
  const _VisitCountDisplay({required this.textColor, required this.accent, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: VisitCounter.instance,
      builder: (context, _) {
        final today = VisitCounter.instance.today;
        final total = VisitCounter.instance.total;
        if (today == null || total == null) return const SizedBox.shrink();
        final labelSize = isDesktop ? 13.0 : 11.5;
        final valueSize = isDesktop ? 15.0 : 13.0;

        Widget stat(String label, int value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(fontSize: labelSize, fontWeight: FontWeight.w600, color: textColor)),
              Text(
                _formatCount(value),
                style: TextStyle(fontSize: valueSize, fontWeight: FontWeight.w800, color: accent),
              ),
            ],
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            stat('오늘 방문자', today),
            SizedBox(width: isDesktop ? 20 : 14),
            stat('누적 방문자', total),
          ],
        );
      },
    );
  }

  String _formatCount(int count) {
    final s = count.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}
