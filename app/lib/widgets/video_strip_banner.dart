import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';
import '../theme/ott_theme.dart';
import 'nav_items.dart';
import 'rolling_banner.dart';

/// 쿠팡플레이 스타일 히어로 — 데스크톱에서만 영상을 화면 폭 전체(가장자리 없이)로 재생하고,
/// 모바일에서는 영상 없이 배너 4개를 합친 가로 롤링배너만 보여준다.
class VideoStripBanner extends StatefulWidget {
  final String videoAsset;
  final double aspectRatio;
  final VoidCallback? onCtaTap;
  final int navSelectedIndex;
  final ValueChanged<int> onNavSelected;

  const VideoStripBanner({
    super.key,
    this.videoAsset = 'assets/videos/studybox_intro.mp4',
    this.aspectRatio = 3.6,
    this.onCtaTap,
    required this.navSelectedIndex,
    required this.onNavSelected,
  });

  @override
  State<VideoStripBanner> createState() => _VideoStripBannerState();
}

class _VideoStripBannerState extends State<VideoStripBanner> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    if (isDesktop && _controller == null) {
      _initVideo();
    }
  }

  void _initVideo() {
    final controller = VideoPlayerController.asset(widget.videoAsset);
    _controller = controller;
    controller
        .initialize()
        .then((_) async {
          if (!mounted) return;
          await controller.setLooping(true);
          await controller.setVolume(0);
          if (!mounted) return;
          setState(() => _ready = true);
          unawaited(controller.play());
        })
        .catchError((_) {
          // 플랫폼에 비디오 플레이어 구현이 없는 환경(예: 위젯 테스트)에서는 조용히 플레이스홀더로 남긴다.
        });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _videoBox() {
    final controller = _controller;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_ready && controller != null)
          IgnorePointer(
            // 웹에서 video_player가 실제 <video> DOM 엘리먼트로 그려져 위에 얹은 버튼의 클릭을
            // 가로채는 문제가 있어, 영상 레이어는 포인터 이벤트를 무시하게 만든다.
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.0),
                  OttColors.bg.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.22, 0.62, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          left: 28,
          top: 26,
          child: Text(
            'STUDY BOX - 나만의 화면 속, 합격 상자가 열린다',
            style: GoogleFonts.blackHanSans(
              fontSize: 22,
              color: Colors.white,
              letterSpacing: 0.3,
              shadows: [
                Shadow(color: Colors.black.withValues(alpha: 0.7), blurRadius: 16),
                Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
              ],
            ),
          ),
        ),
        Positioned(
          right: 24,
          bottom: 28,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onCtaTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 5))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow_rounded, color: OttColors.accentStart, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      '지금 학습 시작하기',
                      style: GoogleFonts.notoSansKr(color: const Color(0xFF1B1240), fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 28,
          bottom: 28,
          child: _HeroNavRow(selectedIndex: widget.navSelectedIndex, onSelected: widget.onNavSelected),
        ),
      ],
    );
  }

  static const _mobileBanners = [
    BannerItem(
      title: '배너 1',
      subtitle: '준비 중인 프로모션 영역',
      icon: Icons.campaign_outlined,
      gradient: [Color(0xFF1B1240), Color(0xFF3B2E6E)],
    ),
    BannerItem(
      title: '배너 2',
      subtitle: '준비 중인 프로모션 영역',
      icon: Icons.campaign_outlined,
      gradient: [Color(0xFF141B33), Color(0xFF2A3B66)],
    ),
    BannerItem(
      title: '배너 3',
      subtitle: '준비 중인 프로모션 영역',
      icon: Icons.campaign_outlined,
      gradient: [Color(0xFF232B45), Color(0xFF1B1240)],
    ),
    BannerItem(
      title: '배너 4',
      subtitle: '준비 중인 프로모션 영역',
      icon: Icons.campaign_outlined,
      gradient: [Color(0xFF1B1240), Color(0xFF2A3B66)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    if (!isDesktop) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: RollingBanner(
          activeDotColor: OttColors.accentStart,
          inactiveDotColor: OttColors.border,
          aspectRatio: 5.2,
          banners: _mobileBanners,
        ),
      );
    }

    return ClipRect(
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: ColoredBox(color: Colors.black, child: _videoBox()),
      ),
    );
  }
}

/// 영상 좌측 하단에 오버레이하는 메뉴 — 쿠팡플레이 스타일 둥근 불투명 필, 간격 촘촘하게 한 줄로 배치.
class _HeroNavRow extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const _HeroNavRow({required this.selectedIndex, required this.onSelected});

  Widget _pill(BuildContext context, String label, {required bool selected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? OttColors.accentStart : Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainItems = kNavItems.where((item) => item.label != '마이페이지');
    final myPage = kNavItems.firstWhere((item) => item.label == '마이페이지');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...mainItems.map(
          (item) => _pill(
            context,
            item.label,
            selected: item.tabIndex == selectedIndex,
            onTap: () => onSelected(item.tabIndex),
          ),
        ),
        _pill(
          context,
          '회원가입',
          selected: false,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입 기능은 준비 중이에요.')),
          ),
        ),
        _pill(
          context,
          '로그인',
          selected: false,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인 기능은 준비 중이에요.')),
          ),
        ),
        _pill(context, myPage.label, selected: myPage.tabIndex == selectedIndex, onTap: () => onSelected(myPage.tabIndex)),
      ],
    );
  }
}
