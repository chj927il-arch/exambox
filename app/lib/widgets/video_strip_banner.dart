import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';
import '../theme/ott_theme.dart';
import 'nav_items.dart';

/// 쿠팡플레이 스타일 히어로 — 모바일/데스크톱 모두 영상을 화면 폭 전체(가장자리 없이)로 재생하고,
/// 그 위에 타이틀·CTA·메뉴를 오버레이한다. 모바일은 폰트/여백/영상 비율만 더 작게 조정한다.
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
    if (_controller == null) {
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

  Widget _videoBox(bool isDesktop) {
    final controller = _controller;
    final titlePad = isDesktop ? 28.0 : 16.0;
    final ctaPad = isDesktop ? 24.0 : 16.0;

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
        if (isDesktop)
          Positioned(
            left: titlePad,
            top: 26,
            right: titlePad,
            child: Text(
              'STUDY BOX - 나만의 화면 속, 합격 상자가 열린다',
              maxLines: 1,
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
          )
        else
          // 모바일은 화면이 좁아 타이틀과 메뉴를 좌측 상단에 세로로 쌓아 겹치지 않게 한다.
          Positioned(
            left: titlePad,
            top: 14,
            right: titlePad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'STUDY BOX - 나만의 화면 속, 합격 상자가 열린다',
                  maxLines: 2,
                  style: GoogleFonts.blackHanSans(
                    fontSize: 15,
                    color: Colors.white,
                    letterSpacing: 0.3,
                    shadows: [
                      Shadow(color: Colors.black.withValues(alpha: 0.7), blurRadius: 16),
                      Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _HeroNavRow(
                  selectedIndex: widget.navSelectedIndex,
                  onSelected: widget.onNavSelected,
                  compact: true,
                ),
              ],
            ),
          ),
        Positioned(
          right: ctaPad,
          bottom: isDesktop ? 28 : 16,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onCtaTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16, vertical: isDesktop ? 14 : 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 5))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: OttColors.accentStart, size: isDesktop ? 22 : 18),
                    const SizedBox(width: 6),
                    Text(
                      '지금 학습 시작하기',
                      style: GoogleFonts.notoSansKr(
                        color: const Color(0xFF1B1240),
                        fontWeight: FontWeight.w800,
                        fontSize: isDesktop ? 16 : 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isDesktop)
          Positioned(
            right: 24,
            top: 24,
            child: _HeroNavRow(
              selectedIndex: widget.navSelectedIndex,
              onSelected: widget.onNavSelected,
              compact: false,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    return ClipRect(
      child: AspectRatio(
        aspectRatio: isDesktop ? widget.aspectRatio : 16 / 9,
        child: ColoredBox(color: Colors.black, child: _videoBox(isDesktop)),
      ),
    );
  }
}

/// 영상 우측 상단에 오버레이하는 메뉴 — 쿠팡플레이 스타일 둥근 불투명 필.
/// 자격증/공지사항/FAQ는 요청에 따라 일단 비노출, 홈/회원가입/로그인/마이페이지만 노출.
class _HeroNavRow extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool compact;
  const _HeroNavRow({required this.selectedIndex, required this.onSelected, this.compact = false});

  Widget _pill(BuildContext context, String label, {required bool selected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: compact ? 6 : 8),
        decoration: BoxDecoration(
          color: selected ? OttColors.accentStart : Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: compact ? 11 : 13, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = kNavItems.firstWhere((item) => item.label == '홈');
    final myPage = kNavItems.firstWhere((item) => item.label == '마이페이지');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _pill(context, home.label, selected: home.tabIndex == selectedIndex, onTap: () => onSelected(home.tabIndex)),
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
