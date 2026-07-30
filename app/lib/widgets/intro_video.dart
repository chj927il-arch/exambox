import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import 'vertical_rolling_banner.dart';

/// 홈 상단 인트로 영상 — 음소거 자동재생 + 끊김 없는 무한 반복.
/// 영상을 왼쪽으로 정렬해 오른쪽에 생기는 여백에는 세로 롤링배너를 배치한다.
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
    _controller = VideoPlayerController.asset('assets/videos/studybox_intro.mp4');
    _controller.initialize().then((_) async {
      if (!mounted) return;
      await _controller.setLooping(true);
      await _controller.setVolume(0);
      if (!mounted) return;
      setState(() => _ready = true);
      unawaited(_controller.play());
    }).catchError((_) {
      // 플랫폼에 비디오 플레이어 구현이 없는 환경(예: 위젯 테스트)에서는 조용히 플레이스홀더로 남긴다.
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 21 / 9,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final videoAspect = _ready ? _controller.value.aspectRatio : 16 / 9;
          final videoWidth = (constraints.maxHeight * videoAspect).clamp(0.0, constraints.maxWidth);

          return Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Colors.black),
              // 영상을 왼쪽 끝에 정렬 — 원본 비율 그대로, 잘리지 않게 표시.
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: videoWidth,
                  height: constraints.maxHeight,
                  child: _ready
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              // 영상 영역에만 어둡게 + 검은 그라데이션 (오른쪽 배너 영역은 그대로 둠).
              Positioned(
                left: 0,
                top: 0,
                width: videoWidth,
                height: constraints.maxHeight,
                child: IgnorePointer(
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
                          style: GoogleFonts.blackHanSans(fontSize: 18, color: Colors.white, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 영상 오른쪽 여백 — 세로 롤링배너.
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
    );
  }
}
