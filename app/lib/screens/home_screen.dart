import 'package:flutter/material.dart';
import '../config/feature_flags.dart';
import '../data/board_data.dart';
import '../data/lecture_data.dart';
import '../models/exam_subject.dart';
import '../theme/app_theme.dart';
import '../theme/ott_theme.dart';
import '../theme/subject_style.dart';
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

/// 홈 화면 — 넷플릭스/디즈니+/쿠팡플레이 같은 OTT 스타일(다크모드 + 가로 포스터행)로 개편.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    return ColoredBox(
      color: OttColors.bg,
      child: ListView(
        padding: const EdgeInsets.only(top: 22, bottom: 28),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _StartStudyBanner(
              title: '지금 학습 시작하기',
              subtitle: '가맹거래사',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CertificateMenuScreen(certId: 'franchise_broker', certName: '가맹거래사'),
                ),
              ),
            ),
          ),
          if (kKoreanHistoryEnabled) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _StartStudyBanner(
                title: '한국사능력검정 학습하기',
                subtitle: '한국사능력검정',
                color: AppColors.accentPurple,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CertificateMenuScreen(certId: 'korean_history', certName: '한국사능력검정'),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          // PC: 세 배너를 나란히 병렬 배치(한눈에 다 보이게). 모바일: 폭이 좁아 기존처럼 롤링으로 유지.
          if (isDesktop)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _ParallelPromoBanners(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: const RollingBanner(
                    banners: [
                      BannerItem(imageAsset: 'assets/images/rolling_banner_update.png'),
                      BannerItem(imageAsset: 'assets/images/rolling_banner_chapter.png'),
                      BannerItem(imageAsset: 'assets/images/rolling_banner_premium.png'),
                    ],
                  ),
                ),
              ),
            ),
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

/// 영상 히어로를 대체하는 심플한 학습 시작 배너 — 해당 자격증 학습 화면으로 바로 이동.
class _StartStudyBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _StartStudyBanner({
    required this.title,
    required this.subtitle,
    this.color = OttColors.accentStart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white70, letterSpacing: 1),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

/// PC 전용 — 영상 바로 아래 프로모션 배너 3개를 롤링 대신 나란히 병렬 배치.
/// (모바일은 폭이 좁아 계속 롤링 캐러셀을 사용한다.)
const List<String> _kParallelBannerAssets = [
  'assets/images/rolling_banner_update.png',
  'assets/images/rolling_banner_chapter.png',
  'assets/images/rolling_banner_premium.png',
];

class _ParallelPromoBanners extends StatelessWidget {
  const _ParallelPromoBanners();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _kParallelBannerAssets.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: _ParallelBannerCard(asset: _kParallelBannerAssets[i])),
        ],
      ],
    );
  }
}

class _ParallelBannerCard extends StatelessWidget {
  final String asset;
  const _ParallelBannerCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      // 배너 원본 이미지가 대략 3:1 비율이라 셋 다 동일하게 맞춘다.
      aspectRatio: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }
}

/// 포스터 카드 공통 규격 — 민법 특강·과목별 학습 표지 이미지 모두 세로형(약 0.71 비율)이라
/// 넷플릭스 포스터 비율에 가깝게 좁고 촘촘한 크기 하나로 통일한다.
const double kLecturePosterWidth = 152;
const double kLecturePosterHeight = 216;

/// 원본 표지 이미지(밝은 배경의 홍보 배너 톤)를 다크 테마에 맞게 어둡게 톤다운하고,
/// 하단에 텍스트 가독용 그라데이션 스크림을 얹는 공통 래퍼.
class TintedPoster extends StatelessWidget {
  final String imageAsset;
  final Widget? bottomOverlay;
  const TintedPoster({super.key, required this.imageAsset, this.bottomOverlay});

  @override
  Widget build(BuildContext context) {
    // CanvasKit(웹)이 큰 원본 이미지를 화면에 그릴 때 스케일을 잘못 잡아 흐릿하게 보이는 문제가 있어,
    // 카드 실제 표시 크기(devicePixelRatio 반영)에 맞춰 미리 디코드 크기를 지정해 선명하게 그린다.
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (kLecturePosterWidth * dpr).round();
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: ResizeImage(AssetImage(imageAsset), width: cacheWidth),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
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

