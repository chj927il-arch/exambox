import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/ott_theme.dart';

/// 홈 화면 상단에 보여주는 인트로 영상 — 소리 없이 무한 자동반복 재생된다.
class HomeIntroVideo extends StatefulWidget {
  final String videoAsset;
  final double aspectRatio;

  const HomeIntroVideo({
    super.key,
    this.videoAsset = 'assets/videos/home_intro.mp4',
    this.aspectRatio = 16 / 9,
  });

  @override
  State<HomeIntroVideo> createState() => _HomeIntroVideoState();
}

class _HomeIntroVideoState extends State<HomeIntroVideo> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
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
          // 비디오 플레이어 구현이 없는 환경(예: 위젯 테스트)에서는 조용히 플레이스홀더로 남긴다.
        });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: ColoredBox(
          color: OttColors.surface,
          child: _ready && controller != null
              ? FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
