import 'dart:async';

import 'package:flutter/material.dart';

class SideRollingBannerItem {
  final String label;
  final Color color;
  const SideRollingBannerItem({required this.label, required this.color});
}

const kLeftSideBanners = [
  SideRollingBannerItem(label: '배너 1', color: Color(0xFF3B2E6E)),
  SideRollingBannerItem(label: '배너 2', color: Color(0xFF2A3B66)),
];

const kRightSideBanners = [
  SideRollingBannerItem(label: '배너 3', color: Color(0xFF1B1240)),
  SideRollingBannerItem(label: '배너 4', color: Color(0xFF232B45)),
];

/// 영상 띠배너 좌우 레터박스 여백에 배치하는 얇은 세로 롤링배너 — 2개 슬라이드가 위→아래로 순환한다.
class SideRollingBanner extends StatefulWidget {
  final List<SideRollingBannerItem> items;
  const SideRollingBanner({super.key, this.items = kLeftSideBanners});

  @override
  State<SideRollingBanner> createState() => _SideRollingBannerState();
}

class _SideRollingBannerState extends State<SideRollingBanner> {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_page + 1) % widget.items.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 650), curve: Curves.easeOut);
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
      itemCount: widget.items.length,
      onPageChanged: (i) => setState(() => _page = i),
      itemBuilder: (context, i) {
        final item = widget.items[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
          child: Container(
            decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              item.label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}
