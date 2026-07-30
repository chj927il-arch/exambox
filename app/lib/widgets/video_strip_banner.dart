import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';
import '../theme/ott_theme.dart';
import 'rolling_banner.dart';
import 'side_rolling_banner.dart';

/// 축구장 광고판(피치사이드 LED 보드) 같은 얇고 긴 띠 형태로 영상을 무한 반복 송출하는 배너.
/// 데스크톱에서만 영상을 재생하고(좌우 레터박스 여백엔 세로 롤링배너), 모바일에서는 영상 없이
/// 좌우 배너 4개를 합친 가로 롤링배너만 보여준다.
class VideoStripBanner extends StatefulWidget {
  final String videoAsset;
  final double aspectRatio;

  const VideoStripBanner({
    super.key,
    this.videoAsset = 'assets/videos/studybox_intro.mp4',
    this.aspectRatio = 3.6,
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
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.32),
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.32),
                ],
                stops: const [0.0, 0.25, 0.75, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          top: 10,
          child: Text(
            'STUDY BOX',
            style: GoogleFonts.blackHanSans(fontSize: 13, color: Colors.white, letterSpacing: 0.5),
          ),
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
        child: ColoredBox(
          color: Colors.black,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final videoAspect = _controller != null && _ready ? _controller!.value.aspectRatio : 16 / 9;
              final videoWidth = (constraints.maxHeight * videoAspect).clamp(0.0, constraints.maxWidth);
              final margin = (constraints.maxWidth - videoWidth) / 2;
              final showSideBanners = margin >= 60;

              return Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    child: SizedBox(width: videoWidth, height: constraints.maxHeight, child: _videoBox()),
                  ),
                  if (showSideBanners) ...[
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: margin,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: SideRollingBanner(items: kLeftSideBanners),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: margin,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: SideRollingBanner(items: kRightSideBanners),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
