import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'exam_intro_screen.dart';
import 'exam_subjects_screen.dart';
import 'korean_history_intro_screen.dart';
import 'korean_history_level_screen.dart';
import 'study_screen.dart';

/// 학습하기 화면의 라우트 이름 — 퀴즈 완료 후 "끝내기"를 눌렀을 때 이 화면까지만
/// 되돌아가기 위해 사용한다(popUntil(isFirst)는 자격증 탭 목록까지 돌아가버리므로 부적절).
const studyScreenRouteName = '/study';

class _MenuEntry {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
  final String? routeName;
  const _MenuEntry({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
    this.routeName,
  });
}

/// 자격증(예: 가맹거래사, 한국사능력검정) 선택 시 보여주는 하위 메뉴.
/// 자격증마다 메뉴 구성이 달라 certId로 분기한다.
class CertificateMenuScreen extends StatelessWidget {
  final String certId;
  final String certName;
  const CertificateMenuScreen({super.key, required this.certId, required this.certName});

  List<_MenuEntry> _entriesFor(String certId) {
    switch (certId) {
      case 'korean_history':
        return [
          _MenuEntry(
            label: '시험소개',
            subtitle: '자격 소개 · 시험 안내',
            icon: Icons.info_outline_rounded,
            color: const Color(0xFF8C3B3B),
            builder: (_) => const KoreanHistoryIntroScreen(),
          ),
          _MenuEntry(
            label: '학습하기',
            subtitle: '심화·기본 등급별 시대별 유사문제 풀이',
            icon: Icons.edit_note_outlined,
            color: AppColors.correct,
            builder: (_) => const KoreanHistoryLevelScreen(),
            routeName: studyScreenRouteName,
          ),
        ];
      case 'franchise_broker':
      default:
        return [
          _MenuEntry(
            label: '시험소개',
            subtitle: '자격 소개 · 시험 안내',
            icon: Icons.info_outline_rounded,
            color: AppColors.primary,
            builder: (_) => const ExamIntroScreen(),
          ),
          _MenuEntry(
            label: '시험과목',
            subtitle: '과목별 소개 · 출제경향',
            icon: Icons.menu_book_outlined,
            color: AppColors.accentGold,
            builder: (_) => const ExamSubjectsScreen(),
          ),
          _MenuEntry(
            label: '학습하기',
            subtitle: '챕터별 유사문제 풀이',
            icon: Icons.edit_note_outlined,
            color: AppColors.correct,
            builder: (_) => const StudyScreen(),
            routeName: studyScreenRouteName,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entriesFor(certId);

    return Scaffold(
      appBar: AppBar(title: Text(certName), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(
            '$certName 메뉴',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            '원하는 메뉴를 선택해주세요',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MenuCard(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final _MenuEntry entry;
  const _MenuCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: entry.color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            settings: entry.routeName != null ? RouteSettings(name: entry.routeName) : null,
            builder: entry.builder,
          )),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: entry.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
                  child: Icon(entry.icon, color: entry.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Text(entry.subtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
