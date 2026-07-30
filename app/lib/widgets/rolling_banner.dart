import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class BannerItem {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final List<Color>? gradient;
  final String? imageAsset;
  final VoidCallback? onTap;

  const BannerItem({
    this.title,
    this.subtitle,
    this.icon,
    this.gradient,
    this.imageAsset,
    this.onTap,
  });
}

const _defaultBanners = [
  BannerItem(imageAsset: 'assets/images/rolling_banner_update.png'),
  BannerItem(imageAsset: 'assets/images/rolling_banner_chapter.png'),
  BannerItem(imageAsset: 'assets/images/rolling_banner_korean_history.png'),
];

/// 홈 상단 프로모션/광고 영역 — 3개 배너를 자동으로 롤링하는 캐러셀.
class RollingBanner extends StatefulWidget {
  final List<BannerItem> banners;
  final Color activeDotColor;
  final Color inactiveDotColor;
  final double aspectRatio;

  const RollingBanner({
    super.key,
    this.banners = _defaultBanners,
    this.activeDotColor = AppColors.primary,
    this.inactiveDotColor = AppColors.trackBg,
    this.aspectRatio = 2172 / 724,
  });

  @override
  State<RollingBanner> createState() => _RollingBannerState();
}

class _RollingBannerState extends State<RollingBanner> {
  late final PageController _controller;
  int _page = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_page + 1) % widget.banners.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
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
    return Column(
      children: [
        AspectRatio(
          // 배너 이미지의 실제 비율(약 2172x724)에 맞춰 잘림 없이 표시한다. 텍스트 플레이스홀더 등은 더 얇은 비율로 오버라이드 가능.
          aspectRatio: widget.aspectRatio,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => _BannerCard(item: widget.banners[i]),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? widget.activeDotColor : widget.inactiveDotColor,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerItem item;
  const _BannerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.imageAsset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onTap,
            child: Image.asset(item.imageAsset!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.gradient!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title!,
                  style: GoogleFonts.blackHanSans(color: Colors.white, fontSize: 22, height: 1.15, letterSpacing: 0.2),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.subtitle!,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.95), fontSize: 13, fontWeight: FontWeight.w600, height: 1.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), shape: BoxShape.circle),
            child: Icon(item.icon!, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
