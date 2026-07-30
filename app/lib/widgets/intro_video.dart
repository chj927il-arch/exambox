import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';
import 'vertical_rolling_banner.dart';

/// 홈 상단 인트로 영상 — 음소거 자동재생 + 끊김 없는 무한 반복.
/// 데스크톱: 영상을 왼쪽 정렬하고 오른쪽 여백에 세로(위→아래) 롤링배너를 배치.
/// 모바일: 영상 옆 여백이 좁아 잘 안 보이므로, 영상을 전체 폭으로 두고 그 아래에
/// 가로로 넘어가는 롤링배너를 배치한다.
class IntroVideo extends StatefulWidget {
  const IntroVideo({super.key});

  @override
  State<IntroVideo> createState() => _IntroVideoState();
}

class _IntroVideoState extends State<IntroVideo> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/videos/studybox_intro.mp4',
    );
    _controller
        .initialize()
        .then((_) async {
          if (!mounted) return;
          await _controller.setLooping(true);
          await _controller.setVolume(0);
          if (!mounted) return;
          setState(() => _ready = true);
          unawaited(_controller.play());
        })
        .catchError((_) {
          // 플랫폼에 비디오 플레이어 구현이 없는 환경(예: 위젯 테스트)에서는 조용히 플레이스홀더로 남긴다.
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _videoSurface({required double titleFontSize}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        if (_ready)
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        IgnorePointer(
          child: Stack(
            children: [
              ColoredBox(color: Colors.black.withValues(alpha: 0.22)),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.45),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                right: 14,
                top: 12,
                child: Text(
                  'STUDY BOX',
                  style: GoogleFonts.blackHanSans(
                    fontSize: titleFontSize,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    return isDesktop ? _buildDesktop() : _buildMobile();
  }

  /// 데스크톱 — 21:9 영역 안에서 영상을 왼쪽 정렬하고, 남는 오른쪽 폭에 세로 롤링배너.
  Widget _buildDesktop() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 21 / 9,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final videoAspect = _ready ? _controller.value.aspectRatio : 16 / 9;
            final videoWidth = (constraints.maxHeight * videoAspect).clamp(
              0.0,
              constraints.maxWidth,
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Colors.black),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: videoWidth,
                    height: constraints.maxHeight,
                    child: _videoSurface(titleFontSize: 18),
                  ),
                ),
                Positioned(
                  left: videoWidth,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: VerticalRollingBanner(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 모바일 — 영상을 전체 폭(16:9)으로 표시. 롤링배너는 홈 화면 상단(응원바 아래)에서 별도로 노출된다.
  Widget _buildMobile() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _videoSurface(titleFontSize: 14),
      ),
    );
  }
}
