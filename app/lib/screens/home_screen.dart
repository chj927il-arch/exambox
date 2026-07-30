import 'package:flutter/material.dart';
import '../data/board_data.dart';
import '../data/lecture_data.dart';
import '../models/exam_subject.dart';
import '../theme/app_theme.dart';
import '../theme/ott_theme.dart';
import '../theme/subject_style.dart';
import '../widgets/encourage_bar.dart';
import '../widgets/hscroll_list.dart';
import '../widgets/marquee_row.dart';
import '../widgets/rolling_banner.dart';
import 'certificate_menu_screen.dart';
import 'daily_ox_list_screen.dart';
import 'lecture_grid_screen.dart';
import 'lecture_intro_screen.dart';
import 'review_screen.dart';
import 'subject_grid_screen.dart';
import 'subject_info_screen.dart';

/// 홈 화면 — 넷플릭스/디즈니+/쿠팡플레이 같은 OTT 스타일(다크모드 + 히어로 배너 + 가로 포스터행)로 개편.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: OttColors.bg,
      child: ListView(
        padding: const EdgeInsets.only(top: 14, bottom: 28),
        children: [
          const EncourageBar(),
          const SizedBox(height: 14),
          const _HomeRollingBanner(),
          const SizedBox(height: 22),
          const _HeroBanner(),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _RowHeader(
              title: '과목별 학습',
              onMore: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubjectGridScreen())),
            ),
          ),
          const SizedBox(height: 10),
          const _SubjectPosterRow(),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _RowHeader(
              title: '민법 특강',
              onMore: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LectureGridScreen())),
            ),
          ),
          const SizedBox(height: 10),
          const _LectureGrid(),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _RowHeader(title: '오늘의 OX 퀴즈'),
          ),
          const SizedBox(height: 10),
          HScrollList(
            height: kLecturePosterHeight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 1,
            itemBuilder: (context, index) => _DailyOxMainCard(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DailyOxListScreen())),
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _RowHeader(
              title: '수강후기',
              onMore: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReviewScreen())),
            ),
          ),
          const SizedBox(height: 10),
          const _ReviewCarousel(),
        ],
      ),
    );
  }
}

/// 포스터 카드 공통 규격 — 민법 특강·과목별 학습 표지 이미지 모두 세로형(약 0.71 비율)이라
/// 넷플릭스 포스터 비율에 가깝게 좁고 촘촘한 크기 하나로 통일한다.
const double kLecturePosterWidth = 138;
const double kLecturePosterHeight = 196;

/// 원본 표지 이미지(밝은 배경의 홍보 배너 톤)를 다크 테마에 맞게 어둡게 톤다운하고,
/// 하단에 텍스트 가독용 그라데이션 스크림을 얹는 공통 래퍼.
class TintedPoster extends StatelessWidget {
  final String imageAsset;
  final Widget? bottomOverlay;
  const TintedPoster({super.key, required this.imageAsset, this.bottomOverlay});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(imageAsset, fit: BoxFit.cover),
        // 밝은 홍보 배너 톤을 다크 테마에 맞게 살짝만 톤다운(원본이 안 보일 정도로 어둡게 하지 않음).
        Positioned.fill(child: ColoredBox(color: Colors.black.withValues(alpha: 0.18))),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.0), Colors.black.withValues(alpha: 0.45)],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),
        if (bottomOverlay != null)
          Positioned(left: 0, right: 0, bottom: 0, child: bottomOverlay!),
      ],
    );
  }
}

/// 히어로 배너 — 진한 네이비→퍼플 그라데이션 위에 브랜드 워드마크 + 한 줄 소개 + CTA 버튼.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    final titleSize = isDesktop ? 40.0 : 23.0;
    final subtitleSize = isDesktop ? 20.0 : 14.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B1240), Color(0xFF141B33), OttColors.bg],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '가맹거래사 1차 시험',
            style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            '가장 스마트하게, 가장 콤팩트하게 준비하세요',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: subtitleSize, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.2),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CertificateMenuScreen(certId: 'franchise_broker', certName: '가맹거래사'),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [OttColors.accentStart, OttColors.accentEnd]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 6),
                  Text(
                    '지금 학습 시작하기',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 가로 스크롤 섹션 타이틀 + "더보기" 버튼(있을 때만) — 누르면 해당 그리드 전체를 새 화면에서 보여준다.
class _RowHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMore;
  const _RowHeader({required this.title, this.onMore});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.2),
          ),
        ),
        if (onMore != null)
          InkWell(
            onTap: onMore,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('더보기', style: TextStyle(fontSize: 12.5, color: OttColors.textSecondary, fontWeight: FontWeight.w700)),
                  Icon(Icons.chevron_right_rounded, size: 16, color: OttColors.textSecondary),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 과목(경제법·민법·경영학) 포스터 카드 — 표지 이미지 + 하단 정보 패널(다크 카드).
class _SubjectPosterRow extends StatelessWidget {
  const _SubjectPosterRow();

  @override
  Widget build(BuildContext context) {
    return HScrollList(
      height: kLecturePosterHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: examSubjects.length,
      itemBuilder: (context, index) => SubjectPosterCard(subject: examSubjects[index]),
    );
  }
}

/// 경영학은 아직 표지 이미지가 없어 자리만 잡아둔 상태 — 이미지 도착하면 여기 추가.
String? subjectCoverImage(String subjectId) {
  switch (subjectId) {
    case 'economic_law':
      return 'assets/images/subject_cover_economic_law.png';
    case 'civil_law':
      return 'assets/images/subject_cover_civil_law.png';
    default:
      return null;
  }
}

class SubjectPosterCard extends StatelessWidget {
  final ExamSubject subject;
  const SubjectPosterCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final style = subjectStyleOf(subject.id);
    final coverImage = subjectCoverImage(subject.id);

    final titleOverlay = Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            subject.name,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            subject.categories.join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: OttColors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SubjectInfoScreen(subjectId: subject.id, subjectName: subject.name)),
      ),
      child: Container(
        width: kLecturePosterWidth,
        height: kLecturePosterHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OttColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 14, offset: const Offset(0, 8)),
          ],
        ),
        // 표지 이미지가 있으면 민법 특강 포스터처럼 이미지 안에 제목이 포함돼 있어 별도 오버레이 없이 그대로 보여준다.
        // 아직 이미지가 없는 과목(경영학)만 색상 배경 위에 아이콘+과목명 오버레이로 자리를 채운다.
        child: coverImage != null
            ? TintedPoster(imageAsset: coverImage)
            : Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [style.color, style.color.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 12,
                    child: Icon(style.icon, color: Colors.white, size: 26),
                  ),
                  Positioned(left: 0, right: 0, bottom: 0, child: titleOverlay),
                ],
              ),
      ),
    );
  }
}

/// 민법 특강 — 표지 이미지가 카드 전체를 덮는 포스터형 카드. 데이터는 lecture_data.dart의
/// civilLawLectures를 홈 행과 "더보기"(LectureGridScreen)가 함께 사용한다.
class _LectureGrid extends StatelessWidget {
  const _LectureGrid();

  @override
  Widget build(BuildContext context) {
    return HScrollList(
      height: kLecturePosterHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: civilLawLectures.length,
      itemBuilder: (context, index) {
        final item = civilLawLectures[index];
        return LectureCoverCard(
          imageAsset: item.imageAsset,
          onTap: (context) => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LectureIntroScreen(
                title: item.title,
                keyPoints: item.keyPoints,
                subjectId: item.subjectId,
                subjectName: item.subjectName,
                category: item.category,
              ),
            ),
          ),
        );
      },
    );
  }
}

class LectureCoverCard extends StatelessWidget {
  final String imageAsset;
  final void Function(BuildContext context) onTap;
  const LectureCoverCard({super.key, required this.imageAsset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Container(
        width: kLecturePosterWidth,
        height: kLecturePosterHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OttColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 14, offset: const Offset(0, 8)),
          ],
        ),
        child: TintedPoster(imageAsset: imageAsset),
      ),
    );
  }
}

/// 오늘의 OX 퀴즈 — 회차별로 나누지 않고 "데일리 OX퀴즈" 대표 카드 하나만 노출.
/// 표지 이미지(daily_ox_cover.png)가 민법 특강 포스터와 동일한 규격(138x196)을 그대로 채운다.
class _DailyOxMainCard extends StatelessWidget {
  final VoidCallback onTap;
  const _DailyOxMainCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: kLecturePosterWidth,
        height: kLecturePosterHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OttColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 14, offset: const Offset(0, 8)),
          ],
        ),
        child: const TintedPoster(imageAsset: 'assets/images/daily_ox_cover.png'),
      ),
    );
  }
}

/// 상단 롤링 배너 — 3장이 자동으로 순환되는 프로모션 배너. 실제 배너 이미지는 추후 교체 예정,
/// 지금은 그라데이션 플레이스홀더 3장으로 자리를 채운다.
class _HomeRollingBanner extends StatelessWidget {
  const _HomeRollingBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RollingBanner(
        activeDotColor: OttColors.accentStart,
        inactiveDotColor: OttColors.border,
        banners: const [
          BannerItem(
            title: '배너 1',
            subtitle: '준비 중인 프로모션 영역',
            icon: Icons.campaign_outlined,
            gradient: [Color(0xFF1B1240), Color(0xFF3B2E6E)],
          ),
          BannerItem(
            title: '배너 2',
            subtitle: '준비 중인 프로모션 영역',
            icon: Icons.campaign_outlined,
            gradient: [Color(0xFF141B33), Color(0xFF2A3B66)],
          ),
          BannerItem(
            title: '배너 3',
            subtitle: '준비 중인 프로모션 영역',
            icon: Icons.campaign_outlined,
            gradient: [Color(0xFF232B45), Color(0xFF1B1240)],
          ),
        ],
      ),
    );
  }
}

/// 수강후기 — 카드가 여백 없이 옆으로 흘러가는 롤링 스트립(다크 카드).
class _ReviewCarousel extends StatelessWidget {
  const _ReviewCarousel();

  @override
  Widget build(BuildContext context) {
    return MarqueeRow(
      height: 132,
      pixelsPerSecond: 32,
      itemBuilder: (context) {
        final cards = List.generate(5, (i) => reviews[i % reviews.length]);
        return Row(
          children: [
            for (final review in cards) ...[
              _ReviewMiniCard(review: review),
              const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class _ReviewMiniCard extends StatelessWidget {
  final ReviewItem review;
  const _ReviewMiniCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReviewScreen())),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: OttColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: OttColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14,
                  color: OttColors.accentGold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              review.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, height: 1.3),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                review.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: OttColors.textSecondary, fontWeight: FontWeight.w500, height: 1.35),
              ),
            ),
            Text(
              review.date,
              style: const TextStyle(fontSize: 10.5, color: OttColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

