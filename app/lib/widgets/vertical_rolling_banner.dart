import 'dart:async';
import 'package:flutter/material.dart';

/// 세로로 넘어가는 롤링 배너(위→아래) — 인트로 영상 오른쪽 여백에 배치.
/// 실제 배너 이미지는 추후 교체 예정, 지금은 색상 카드 플레이스홀더로 자리를 채운다.
class VerticalRollingBanner extends StatefulWidget {
  const VerticalRollingBanner({super.key});

  @override
  State<VerticalRollingBanner> createState() => _VerticalRollingBannerState();
}

const _slides = [
  ('배너 1', Color(0xFF3B2E6E)),
  ('배너 2', Color(0xFF2A3B66)),
  ('배너 3', Color(0xFF1B1240)),
];

class _VerticalRollingBannerState extends State<VerticalRollingBanner> {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_page + 1) % _slides.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: _controller,
      itemCount: _slides.length,
      onPageChanged: (i) => setState(() => _page = i),
      itemBuilder: (context, i) {
        final slide = _slides[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Container(
            decoration: BoxDecoration(color: slide.$2, borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              slide.$1,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}
