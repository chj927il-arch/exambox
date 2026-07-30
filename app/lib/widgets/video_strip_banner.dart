import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 축구장 광고판(피치사이드 LED 보드) 같은 얇고 긴 띠 형태로 영상을 무한 반복 송출하는 배너.
/// 화면 폭 전체를 가장자리 없이 채워서 실제 광고판에 더 가까운 느낌을 준다.
class VideoStripBanner extends StatefulWidget {
  final String videoAsset;
  final double aspectRatio;

  const VideoStripBanner({
    super.key,
    this.videoAsset = 'assets/videos/studybox_intro.mp4',
    this.aspectRatio = 7.2,
  });

  @override
  State<VideoStripBanner> createState() => _VideoStripBannerState();
}

class _VideoStripBannerState extends State<VideoStripBanner> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoAsset);
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

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: ColoredBox(
          color: Colors.black,
          child: _ready
              ? FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const SizedBox.expand(),
        ),
      ),
    );
  }
}
