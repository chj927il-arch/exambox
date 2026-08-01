import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';
import '../theme/ott_theme.dart';

/// 모바일 폭에서 배너를 살짝 더 높게 보여주기 위해 원본 비율에 곱하는 배수(1보다 작을수록 더 높아짐).
/// 값이 작을수록 영상 좌우가 더 크롭된다 — 과하게 낮추면 중요한 장면이 잘릴 수 있어 소폭만 적용.
const double _kMobileHeightBoost = 0.94;

/// 홈 화면 상단에 보여주는 인트로 영상 — 소리 없이 무한 자동반복 재생된다.
/// 데스크톱은 원본 비율 그대로, 모바일은 배너를 살짝 더 높게 보여주기 위해
/// 영상을 확대해 좌우를 아주 조금만 크롭한다(BoxFit.cover).
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
        child: ColoredBox(
          color: OttColors.surface,
          // 웹에서 video_player는 실제 <video> DOM 엘리먼트로 그려져 그 위/아래로
          // 스크롤하려는 터치·휠 이벤트를 영상이 가로채 스크롤이 멈칫거리는 문제가
          // 있었다. 영상 레이어는 포인터 이벤트를 무시하게 해서 스크롤이 항상
          // 부모 ListView로 전달되도록 한다.
          child: IgnorePointer(
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
        ),
      ),
    );
  }
}
