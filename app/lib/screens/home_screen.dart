import 'package:flutter/material.dart';
import '../data/board_data.dart';
import '../data/topic_stats.dart';
import '../models/exam_subject.dart';
import '../theme/app_theme.dart';
import '../theme/subject_style.dart';
import '../widgets/launch_banner.dart';
import '../widgets/marquee_row.dart';
import '../widgets/rolling_banner.dart';
import 'certificate_menu_screen.dart';
import 'daily_ox_list_screen.dart';
import 'faq_screen.dart';
import 'lecture_intro_screen.dart';
import 'notice_screen.dart';
import 'review_screen.dart';
import 'subject_info_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 26, bottom: 24),
      children: [
        // 배너는 좌우 여백 없이 화면 폭 전체를 채운다.
        const LaunchBanner(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const _TrustBadgeCard(),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _SectionTitle(prefix: 'STUDY BOX ', highlight: '콘텐츠', color: AppColors.correct),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: RollingBanner(
            banners: [
              const BannerItem(imageAsset: 'assets/images/rolling_banner_update.png'),
              const BannerItem(imageAsset: 'assets/images/rolling_banner_chapter.png'),
              BannerItem(
                imageAsset: 'assets/images/rolling_banner_korean_history.png',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CertificateMenuScreen(certId: 'korean_history', certName: '한국사능력검정'),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _SectionTitle(prefix: '오늘의 ', highlight: 'OX 퀴즈', color: AppColors.accentPurple),
        ),
        const SizedBox(height: 10),
        const _DailyOxBanner(),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _SectionTitle(prefix: '과목 ', highlight: '안내', color: AppColors.primary),
        ),
        const SizedBox(height: 10),
        const _SubjectGuideCarousel(),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _SectionTitle(prefix: 'STUDY BOX ', highlight: '특강', color: AppColors.accentPurple),
        ),
        const SizedBox(height: 10),
        const _LectureGrid(),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  '수강후기',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('후기 작성 기능은 준비 중이에요.')),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('작성하기'),
                style: TextButton.styleFrom(foregroundColor: AppColors.correct),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const _ReviewCarousel(),
        const SizedBox(height: 24),
        const _MotivationStrip(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _BoardSection(
            title: '자주 묻는 질문',
            icon: Icons.help_outline_rounded,
            headerColor: AppColors.accentGold,
            onMore: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FaqScreen())),
            rows: faqs
                .take(3)
                .map((f) => _BoardRow(leading: 'Q. ', title: f.question))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _BoardSection(
            title: '공지사항',
            icon: Icons.campaign_outlined,
            headerColor: AppColors.primary,
            onMore: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NoticeScreen())),
            rows: notices
                .take(3)
                .map((n) => _BoardRow(
                      leading: n.isNew ? '[NEW] ' : null,
                      title: n.title,
                      trailing: n.date,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// 자주 묻는 질문 위 짧은 동기부여 띠배너 — 첨부 이미지(1536x197 비율) 그대로 표시.
class _MotivationStrip extends StatelessWidget {
  const _MotivationStrip();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1536 / 197,
      child: const Image(
        image: AssetImage('assets/images/motivation_strip.png'),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

/// 기출 분석 신뢰도를 보여주는 배지 카드 — 실제 topic_stats 데이터를 그대로 계산해서 표시.
class _TrustBadgeCard extends StatelessWidget {
  const _TrustBadgeCard();

  @override
  Widget build(BuildContext context) {
    final totalQuestions = economicLawTopicStats.fold<int>(0, (sum, t) => sum + t.questionCount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.correct.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.verified_rounded, color: AppColors.correct, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '경제법 11개년 $totalQuestions문항 전수분석 완료',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                const Text(
                  '민법·경영학은 순차적으로 분석·업데이트할 예정이에요',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "STUDY BOX 콘텐츠" 스타일의 섹션 타이틀 — 뒷부분 단어만 색상으로 강조(테두리 박스 없음).
class _SectionTitle extends StatelessWidget {
  final String prefix;
  final String highlight;
  final Color color;
  const _SectionTitle({required this.prefix, required this.highlight, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          prefix,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        Text(
          highlight,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
        ),
      ],
    );
  }
}

/// 데일리 OX 퀴즈 배너 — 모바일에 맞춰 여백을 넉넉히 준 와이드 이미지(3936x1088) 비율 그대로 표시.
class _DailyOxBanner extends StatelessWidget {
  const _DailyOxBanner();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3936 / 1088,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DailyOxListScreen())),
          child: const Image(
            image: AssetImage('assets/images/daily_ox_banner.png'),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}

/// 과목 안내 — 경제법·민법·경영학 3개 과목을 표지(교재 커버) 느낌으로 보여준다.
/// 수강후기 카드보다 훨씬 큰, A4 비율(210:297)을 모바일에 맞게 줄인 세로형 카드.
/// 자동으로 흘러가지 않고, 손가락으로 옆으로 넘겨서 보는 정지형 스크롤.
class _SubjectGuideCarousel extends StatelessWidget {
  const _SubjectGuideCarousel();

  @override
  Widget build(BuildContext context) {
    // 가맹거래사 시험과목(경제법·민법·경영학)에 이어, 별도 자격증인
    // 한국사능력검정시험도 같은 표지 카드 형태로 안내한다.
    final cards = <_SubjectCoverCard>[
      ...examSubjects.map(
        (subject) => _SubjectCoverCard(
          id: subject.id,
          name: subject.name,
          categories: subject.categories,
          onTap: (context) => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SubjectInfoScreen(subjectId: subject.id, subjectName: subject.name)),
          ),
        ),
      ),
      _SubjectCoverCard(
        id: 'korean_history',
        name: '한국사능력검정시험',
        categories: const ['심화', '기본'],
        onTap: (context) => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CertificateMenuScreen(certId: 'korean_history', certName: '한국사능력검정'),
          ),
        ),
      ),
    ];

    return SizedBox(
      height: 268,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cards.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) => cards[index],
      ),
    );
  }
}

/// STUDY BOX 특강 — 과목 안내 카드(_SubjectCoverCard)와 가로(190)·세로(268) 완전히 동일한 크기.
/// 지금은 반사회질서 법률행위·대리행위·의사표시·불공정한 법률행위 4개만 노출.
class _LectureGrid extends StatelessWidget {
  const _LectureGrid();

  @override
  Widget build(BuildContext context) {
    final cards = [
      _LectureCoverCard(
        imageAsset: 'assets/images/lecture_cover_civil_law.png',
        onTap: (context) => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const LectureIntroScreen(
              title: '반사회질서 법률행위',
              keyPoints: [
                '민법 제103조 — 선량한 풍속 기타 사회질서에 위반하는 내용의 법률행위는 무효',
                '판단 기준시 — 법률행위가 이루어진 성립 당시를 기준으로 판단',
                '동기의 불법 — 불법한 동기가 상대방에게 표시되었거나 상대방이 알았거나 알 수 있었던 경우 무효 가능',
                '효과 — 절대적 무효(선의의 제3자에게도 대항 가능)이며, 무효행위 추인으로도 유효가 되지 않음',
                '대표 판례유형 — 도박자금 대여, 첩계약, 형사사건 성공보수 약정, 이중매매의 적극가담, 보험사기 목적 계약 등',
              ],
              subjectId: 'civil_law',
              subjectName: '민법',
              category: '반사회질서 법률행위',
            ),
          ),
        ),
      ),
      _SubjectCoverCard(
        id: 'agency',
        name: '대리행위 특강',
        categories: const [],
        linkLabel: '특강 보기',
        onTap: (context) => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const LectureIntroScreen(
              title: '대리행위',
              keyPoints: [
                '대리의 의의 — 대리인이 본인을 위한 것임을 표시(현명주의)하고 한 의사표시의 법률효과가 직접 본인에게 귀속되는 제도',
                '대리권 발생원인 — 법률의 규정에 의한 법정대리와 본인의 수권행위에 의한 임의대리로 구분',
                '복대리 — 대리인이 대리권의 범위 내에서 자신의 이름으로 선임한 자기의 대리인이며, 임의대리인은 원칙적으로 본인의 승낙이나 부득이한 사유가 있어야 복대리인을 선임 가능',
                '무권대리 — 대리권 없이 한 대리행위로서 본인의 추인이 있으면 소급하여 유효, 추인 거절 시 무효이며 상대방은 최고권·철회권을 가짐',
                '표현대리 — 대리권이 없거나 범위를 넘은 경우에도 본인에게 책임 있는 외관이 있으면 거래 상대방 보호를 위해 본인이 책임을 지는 제도(제125조·제126조·제129조)',
              ],
              subjectId: 'civil_law',
              subjectName: '민법',
              category: '대리행위',
            ),
          ),
        ),
      ),
      _SubjectCoverCard(
        id: 'declaration_of_intent',
        name: '의사표시 특강',
        categories: const [],
        linkLabel: '특강 보기',
        onTap: (context) => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const LectureIntroScreen(
              title: '의사표시',
              keyPoints: [
                '비진의표시(제107조) — 원칙적으로 표시된 대로 효력이 생기나, 상대방이 진의 아님을 알았거나 알 수 있었을 때에는 무효(선의의 제3자에게는 대항 불가)',
                '통정허위표시(제108조) — 상대방과 통정한 허위 의사표시는 당사자 간에는 무효이나, 선의의 제3자에게는 대항 불가',
                '착오(제109조) — 법률행위 내용의 중요부분에 착오가 있으면 취소 가능하나, 표의자에게 중대한 과실이 있으면 취소 불가(선의의 제3자에게는 대항 불가)',
                '사기·강박(제110조) — 기망행위·해악의 고지로 인한 의사표시는 취소 가능, 제3자의 사기·강박은 상대방이 알았거나 알 수 있었던 경우에 한하여 취소 가능(선의의 제3자에게는 대항 불가)',
                '효력발생시기(제111조) — 상대방 있는 의사표시는 그 통지가 상대방에게 도달한 때 효력이 생김(도달주의)',
              ],
              subjectId: 'civil_law',
              subjectName: '민법',
              category: '의사표시',
            ),
          ),
        ),
      ),
      _SubjectCoverCard(
        id: 'unfair_act',
        name: '불공정한 법률행위 특강',
        categories: const [],
        linkLabel: '특강 보기',
        onTap: (context) => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const LectureIntroScreen(
              title: '불공정한 법률행위',
              keyPoints: [
                '민법 제104조 — 당사자 일방의 궁박·경솔·무경험을 이용하여 현저하게 공정을 잃은 법률행위는 무효',
                '요건 — 궁박·경솔·무경험 중 하나만 갖추어도 되는 택일적 요건 + 급부와 반대급부의 현저한 불균형 + 폭리행위자의 이용의사(악의)',
                '증명책임 — 무효를 주장하는 자가 궁박·경솔·무경험, 현저한 불균형, 폭리행위자의 악의를 모두 주장·증명하여야 함',
                '적용범위 — 대가관계 없는 무상행위(증여 등)와 경매에는 적용되지 않으며, 대리행위의 경우 궁박은 본인을, 경솔·무경험은 대리인을 기준으로 판단',
                '효과 — 절대적 무효로서 무효행위의 추인으로도 유효가 되지 않음(제103조의 특별규정으로 이해)',
              ],
              subjectId: 'civil_law',
              subjectName: '민법',
              category: '불공정한 법률행위',
            ),
          ),
        ),
      ),
    ];

    return SizedBox(
      height: 268,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cards.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) => cards[index],
      ),
    );
  }
}

/// STUDY BOX 특강 전용 카드 — 표지 이미지가 190x268 카드 전체를 그대로 덮는다(하단 정보 영역 없음).
class _LectureCoverCard extends StatelessWidget {
  final String imageAsset;
  final void Function(BuildContext context) onTap;
  const _LectureCoverCard({required this.imageAsset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Container(
        width: 190,
        height: 268,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 8)),
          ],
        ),
        child: Image.asset(imageAsset, fit: BoxFit.cover),
      ),
    );
  }
}

/// 과목별 표지 이미지 — 아직 없는 과목은 null(기존 색상 그라데이션으로 대체).
String? _subjectCoverImage(String subjectId) {
  switch (subjectId) {
    case 'economic_law':
      return 'assets/images/subject_cover_economic_law.png';
    case 'civil_law':
      return 'assets/images/subject_cover_civil_law.png';
    case 'business_admin':
      return 'assets/images/subject_cover_business_admin.png';
    case 'korean_history':
      return 'assets/images/subject_cover_korean_history.png';
    default:
      return null;
  }
}

class _SubjectCoverCard extends StatelessWidget {
  final String id;
  final String name;
  final List<String> categories;
  final void Function(BuildContext context) onTap;
  final String linkLabel;
  const _SubjectCoverCard({
    required this.id,
    required this.name,
    required this.categories,
    required this.onTap,
    this.linkLabel = '과목 안내 보기',
  });

  @override
  Widget build(BuildContext context) {
    final style = subjectStyleOf(id);

    return GestureDetector(
      onTap: () => onTap(context),
      child: Container(
        width: 190,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_subjectCoverImage(id) != null)
                    Image.asset(_subjectCoverImage(id)!, fit: BoxFit.cover)
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [style.color, style.color.withValues(alpha: 0.78)],
                        ),
                      ),
                    ),
                  // 표지 이미지가 있으면 이미지 안에 이미 아이콘·제목이 포함돼 있으므로
                  // 별도 오버레이를 그리지 않는다. 이미지가 없는 과목만 색상 배경 위에 표시.
                  if (_subjectCoverImage(id) == null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(style.icon, color: Colors.white, size: 30),
                          Text(
                            name,
                            style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (categories.isNotEmpty)
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: categories
                            .map((c) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: style.color.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    c,
                                    style: TextStyle(color: style.color, fontSize: 10.5, fontWeight: FontWeight.w700),
                                  ),
                                ))
                            .toList(),
                      ),
                    Row(
                      children: [
                        Text(
                          linkLabel,
                          style: TextStyle(color: style.color, fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        Icon(Icons.chevron_right_rounded, size: 16, color: style.color),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 수강후기 — 5개 카드가 여백 없이 옆으로 계속 흘러가는 롤링 스트립.
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 6)),
          ],
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
                  color: AppColors.accentGold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              review.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.3),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                review.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500, height: 1.35),
              ),
            ),
            Text(
              review.date,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardRow {
  final String? leading;
  final String title;
  final String? trailing;
  const _BoardRow({this.leading, required this.title, this.trailing});
}

class _BoardSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color headerColor;
  final VoidCallback onMore;
  final List<_BoardRow> rows;
  const _BoardSection({required this.title, required this.icon, required this.headerColor, required this.onMore, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.035), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: headerColor.withValues(alpha: 0.10),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: InkWell(
              onTap: onMore,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: headerColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(title, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: headerColor)),
                    ),
                    const Text('더보기', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right_rounded, size: 18, color: headerColor),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          ...List.generate(rows.length, (i) {
            final row = rows[i];
            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onMore,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  if (row.leading != null)
                                    TextSpan(
                                      text: row.leading,
                                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                                    ),
                                  TextSpan(text: row.title),
                                ],
                              ),
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (row.trailing != null) ...[
                            const SizedBox(width: 10),
                            Text(row.trailing!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (i != rows.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            );
          }),
        ],
      ),
    );
  }
}
