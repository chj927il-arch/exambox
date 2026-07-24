import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

/// 시험소개 탭 — 한국사능력검정시험(심화) 개요 안내.
class KoreanHistoryIntroScreen extends StatelessWidget {
  const KoreanHistoryIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('시험소개'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8C3B3B), Color(0xFF5C2626)],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('국사편찬위원회 시행', style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text(
                  '한국사능력검정시험이란?',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 10),
                Text(
                  '우리 역사에 대한 관심을 확산·심화시키고 역사 교육의 위상을 강화하기 위해 국사편찬위원회가 시행하는 시험으로, '
                  '한국사에 대한 폭넓고 종합적인 이해의 정도를 측정한다. 심화(1~3급)와 기본(4~6급)으로 나뉜다.',
                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.6, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('심화 시험 안내'),
          const SizedBox(height: 10),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _LabelValue(label: '응시자격', value: '제한 없음 (연령·학력·경력 무관)'),
                SizedBox(height: 12),
                _LabelValue(label: '문항 수', value: '50문항 (5지선다 객관식, 시대순 출제)'),
                SizedBox(height: 12),
                _LabelValue(label: '시험 시간', value: '80분'),
                SizedBox(height: 12),
                _LabelValue(label: '등급 기준', value: '1급 80점 이상 · 2급 70점 이상 · 3급 60점 이상 (100점 만점)'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('출제 범위'),
          const SizedBox(height: 10),
          GlassCard(
            child: Column(
              children: const [
                _InfoRow(icon: Icons.terrain_outlined, text: '선사시대부터 현대사까지 한국사 전 시대'),
                _Divider(),
                _InfoRow(icon: Icons.timeline_outlined, text: '정치·경제·사회·문화사를 아우르는 통합형 문제 다수 출제'),
                _Divider(),
                _InfoRow(icon: Icons.photo_library_outlined, text: '사료·유물·지도 등 자료를 제시하고 해석하는 문제 비중이 높음'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.trackBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '위 내용은 일반적인 시험 정보를 요약한 것으로, 정확한 시행 일정·접수 방법 등은 반드시 한국사능력검정시험 공식 홈페이지 공고를 확인하세요.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.5),
                  ),
                ),
              ],
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

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFF8C3B3B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: const Color(0xFF8C3B3B)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4)),
        ),
      ],
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  const _LabelValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4)),
        ),
      ],
    );
  }
}
