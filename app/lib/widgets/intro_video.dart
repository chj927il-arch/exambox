import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

/// 홈 상단 인트로 영상 — 음소거 자동재생 + 끊김 없는 무한 반복.
/// 밝기를 살짝 낮추고 위에 검은 그라데이션을 덧대 텍스트/UI와 잘 어울리게 한다.
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
      // 원본 영상 비율(16:9)보다 넓게 잡고 BoxFit.contain으로 표시해, 잘리는 부분 없이
      // 전체 영상이 다 보이면서 영역 높이만 줄어들게 한다(좌우는 검은 배경과 자연스럽게 이어짐).
      aspectRatio: 21 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          if (_ready)
            FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          // 영상이 너무 밝지 않도록 살짝 어둡게 + 검은 그라데이션.
          Positioned.fill(child: ColoredBox(color: Colors.black.withValues(alpha: 0.22))),
          Positioned.fill(
            child: DecoratedBox(
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
    );
  }
}
