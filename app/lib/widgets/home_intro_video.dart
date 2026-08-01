import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/ott_theme.dart';

/// 홈 화면 상단에 보여주는 인트로 영상 — 소리 없이 무한 자동반복 재생된다.
/// 데스크톱·모바일 모두 같은 영상을 원본 비율 그대로 사용하며, 잘라내지(crop) 않는다.
/// 스크롤 목록 밖의 고정 영역에 배치해서 쓴다 — 플랫폼 뷰(<video>)가 스크롤 목록
/// 안에 있으면 스크롤할 때마다 웹 엔진이 그 위치·클립을 매 프레임 다시 계산해야 해서
/// 스크롤 전체가 버벅이는 Flutter Web의 알려진 문제가 있다.
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: IgnorePointer(child: VideoPlayer(controller)),
      ),
    );
  }
}
