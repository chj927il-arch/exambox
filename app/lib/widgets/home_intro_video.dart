import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/ott_theme.dart';

/// 홈 화면 상단에 보여주는 인트로 영상 — 소리 없이 무한 자동반복 재생된다.
/// 데스크톱·모바일 모두 같은 영상을 원본 비율 그대로 사용하며, 잘라내지(crop) 않는다.
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
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 스크롤 중에는 영상 디코딩·재생을 잠시 멈춰 메인 스레드 부담을 줄인다 —
    // 영상이 계속 프레임을 그리는 동안 스크롤 제스처가 버벅이는 걸 완화하기 위함.
    final newPosition = Scrollable.maybeOf(context)?.position;
    if (newPosition != _scrollPosition) {
      _scrollPosition?.isScrollingNotifier.removeListener(_handleScrollingChange);
      _scrollPosition = newPosition;
      _scrollPosition?.isScrollingNotifier.addListener(_handleScrollingChange);
    }
  }

  void _handleScrollingChange() {
    final controller = _controller;
    final position = _scrollPosition;
    if (controller == null || position == null || !controller.value.isInitialized) return;
    if (position.isScrollingNotifier.value) {
      controller.pause();
    } else {
      controller.play();
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
          // 비디오 플레이어 구현이 없는 환경(예: 위젯 테스트)에서는 조용히 플레이스홀더로 남긴다.
        });
  }

  @override
  void dispose() {
    _scrollPosition?.isScrollingNotifier.removeListener(_handleScrollingChange);
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
        child: RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(child: VideoPlayer(controller)),
              // 웹에서 video_player는 실제 <video> DOM 엘리먼트로 그려져, IgnorePointer만으로는
              // 그 위에서 스크롤(휠·터치드래그)하려는 이벤트가 여전히 영상에 먹혀 스크롤이
              // 멈칫거리는 경우가 있었다. 그래서 이 영역 전체를 덮는 투명 레이어를 하나 더 두고,
              // 여기서 받은 휠/드래그 이벤트를 부모 Scrollable로 직접 전달해 확실하게 스크롤되도록 한다.
              Positioned.fill(child: _ScrollForwarder()),
            ],
          ),
        ),
      ),
    );
  }
}

/// 영상 영역에서 발생한 마우스 휠·터치 드래그를 가장 가까운 조상 Scrollable로
/// 그대로 전달하는 투명 레이어. 영상 자체는 클릭/드래그 대상이 아니므로 여기서
/// 모든 포인터 이벤트를 가로채 스크롤 동작으로만 변환해도 안전하다.
class _ScrollForwarder extends StatelessWidget {
  const _ScrollForwarder();

  void _scrollBy(BuildContext context, double delta) {
    final position = Scrollable.maybeOf(context)?.position;
    if (position == null) return;
    final target = (position.pixels + delta).clamp(position.minScrollExtent, position.maxScrollExtent);
    position.jumpTo(target);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _scrollBy(context, event.scrollDelta.dy);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) => _scrollBy(context, -details.delta.dy),
      ),
    );
  }
}
