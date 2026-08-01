import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';
import '../theme/ott_theme.dart';

/// 모바일 폭에서 배너를 살짝 더 높게 보여주기 위해 원본 비율에 곱하는 배수(1보다 작을수록 더 높아짐).
const double _kMobileHeightBoost = 0.88;

/// 홈 화면 상단에 보여주는 인트로 영상 — 소리 없이 무한 자동반복 재생된다.
/// 원본 파일의 실제 가로세로 비율을 그대로 사용하며, 잘라내지(crop) 않는다.
class HomeIntroVideo extends StatefulWidget {
  final String videoAsset;

  const HomeIntroVideo({
    super.key,
    this.videoAsset = 'assets/videos/home_intro.mp4',
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
    if (!_ready || controller == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ColoredBox(color: OttColors.surface),
        ),
      );
    }
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    final nativeRatio = controller.value.aspectRatio;
    final displayRatio = isDesktop ? nativeRatio : nativeRatio * _kMobileHeightBoost;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: displayRatio,
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
    );
  }
}
