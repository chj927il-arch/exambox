import 'package:flutter/material.dart';
import '../data/topic_stats.dart';
import '../theme/app_theme.dart';
import '../theme/subject_style.dart';
import '../widgets/glass_card.dart';
import 'mock_exam_screen.dart';
import 'quiz_screen.dart';

const Map<String, String> _subjectDescriptions = {
  'economic_law': '독점규제 및 공정거래에 관한 법률(공정거래법)과 약관의 규제에 관한 법률(약관법)을 중심으로, '
      '가맹사업 분야에서 실제로 적용되는 경쟁법 이론과 판례를 다룹니다. 시장지배적지위 남용, 부당한 공동행위, '
      '불공정거래행위 등 가맹거래사 실무의 핵심이 되는 과목입니다.',
  'civil_law': '민법총칙·물권법·채권법을 아우르며, 계약의 성립·이행·해제와 같은 법률관계의 기본 원리를 다룹니다. '
      '가맹계약도 결국 민법상 계약의 한 유형이므로, 가맹거래사 실무의 이론적 토대가 되는 과목입니다.',
  'business_admin': '회계·재무관리·마케팅·조직행동/인사관리·생산관리·경영정보시스템 등 경영학 전반의 기초 이론을 폭넓게 다룹니다. '
      '가맹본부의 경영 상태를 진단하고 자문하는 실무 역량의 바탕이 되는 과목입니다.',
};

const Map<String, List<String>> _studyTips = {
  'economic_law': [
    '출제 비중이 가장 높은 약관법(약 25%)과 공정위 조직·절차(약 23%)부터 집중적으로 학습하세요.',
    '조문 암기보다는 판례의 결론과 그 이유를 이해하는 방식으로 접근하면 응용문제에 강해집니다.',
    '기출 문제를 유형별로 반복 학습해 비슷한 함정 선택지에 익숙해지는 것이 중요합니다.',
  ],
  'civil_law': [
    '민법총칙·물권법·채권법 순서로 기본 개념을 먼저 다진 후 판례 문제로 넘어가세요.',
    '조문 번호보다 법률관계의 흐름(성립→효력→소멸)을 그림으로 그려가며 이해하는 것이 효과적입니다.',
    '계약법 파트는 가맹계약 실무와 직결되므로 예시 사례를 통해 반복 학습하세요.',
  ],
  'business_admin': [
    '출제 비중이 가장 높은 회계(약 21%)와 마케팅(약 20%)부터 우선적으로 학습하세요.',
    '회계·재무관리의 계산 문제는 공식을 직접 손으로 써보며 반복 연습하는 것이 가장 효과적입니다.',
    '마케팅·조직행동·인사관리는 개념어 정의를 정확히 암기하는 것만으로도 상당수 문제를 해결할 수 있습니다.',
    '생산관리·경영정보시스템은 최신 용어(식스시그마, ERP, 빅데이터 등) 위주로 정리해두면 응용문제에 강해집니다.',
  ],
};

/// 과목별 기출 분석 근거를 설명하는 안내 문구.
String _analysisNoteFor(String subjectId, bool isAnalyzed) {
  if (!isAnalyzed) return '기출 분석 준비 중입니다';
  switch (subjectId) {
    case 'economic_law':
      return '2016~2026년(제15회~제24회) 기출 440문항 직접 분석';
    case 'civil_law':
      return '2016~2026년(제15회~제24회) 기출 440문항 직접 분석';
    case 'business_admin':
      return '2019·2021~2026년(7개년) 기출 표본 228문항 분석';
    default:
      return '기출 분석 결과를 반영하였습니다';
  }
}

/// 시험과목 상세 — 과목 소개 · 출제경향 · 시험통계 · 학습방법.
class SubjectInfoScreen extends StatelessWidget {
  final String subjectId;
  final String subjectName;

  const SubjectInfoScreen({super.key, required this.subjectId, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    final style = subjectStyleOf(subjectId);
    final chapters = chapterStatsFor(subjectId);
    final isAnalyzed = subjectStatsIsAnalyzed[subjectId] ?? false;
    final description = _subjectDescriptions[subjectId] ?? '';
    final tips = _studyTips[subjectId] ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(subjectName), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: style.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(style.icon, color: style.color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(subjectName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: style.color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => QuizScreen(subjectId: subjectId, subjectName: subjectName)),
              ),
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('문제풀이 시작', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: style.color,
                side: BorderSide(color: style.color, width: 1.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MockExamScreen(subjectId: subjectId, subjectName: subjectName)),
              ),
              icon: const Icon(Icons.timer_outlined),
              label: const Text('실전모의고사 응시 (40문항)', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('과목 소개'),
          const SizedBox(height: 8),
          GlassCard(
            child: Text(description, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('출제경향 · 시험통계'),
          const SizedBox(height: 4),
          Text(
            _analysisNoteFor(subjectId, isAnalyzed),
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          if (chapters.isEmpty)
            GlassCard(
              child: const Text('통계 준비 중입니다.', style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            GlassCard(
              child: Column(
                children: [
                  for (final stat in chapters) ...[
                    _TopicBar(stat: stat, showRatio: isAnalyzed, color: style.color),
                    if (stat != chapters.last) const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 24),
          const _SectionTitle('학습방법'),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              children: List.generate(tips.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(bottom: i == tips.length - 1 ? 0 : 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(color: style.color.withValues(alpha: 0.12), shape: BoxShape.circle),
                        child: Text('${i + 1}', style: TextStyle(color: style.color, fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(tips[i], style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary));
  }
}

class _TopicBar extends StatelessWidget {
  final TopicStat stat;
  final bool showRatio;
  final Color color;
  const _TopicBar({required this.stat, required this.showRatio, required this.color});

  @override
  Widget build(BuildContext context) {
    if (!showRatio) {
      return Row(
        children: [
          const Icon(Icons.circle, size: 6, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(stat.topic, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      );
    }

    final percent = (stat.ratio * 100).toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(stat.topic, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ),
            const SizedBox(width: 8),
            Text(
              '${stat.questionCount}문항 · $percent%',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: stat.ratio,
            minHeight: 7,
            backgroundColor: AppColors.trackBg,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
