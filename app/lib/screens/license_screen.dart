import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'certificate_menu_screen.dart';

class _LicenseCategory {
  final String name;
  final IconData icon;
  final List<_LicenseItem> items;
  const _LicenseCategory({required this.name, required this.icon, required this.items});
}

class _LicenseItem {
  final String id;
  final String name;
  final String? subtitle;
  final bool ready;
  const _LicenseItem({required this.id, required this.name, this.subtitle, this.ready = true});
}

const _categories = [
  _LicenseCategory(
    name: '전문자격사',
    icon: Icons.balance_outlined,
    items: [
      _LicenseItem(id: 'franchise_broker', name: '가맹거래사', subtitle: '1차 시험대비'),
      _LicenseItem(id: 'labor_attorney', name: '공인노무사', ready: false),
      _LicenseItem(id: 'patent_attorney', name: '변리사', ready: false),
    ],
  ),
  _LicenseCategory(
    name: 'IT',
    icon: Icons.memory_outlined,
    items: [
      _LicenseItem(id: 'info_processing', name: '정보처리기사', ready: false),
      _LicenseItem(id: 'sqld', name: 'SQLD', ready: false),
    ],
  ),
  _LicenseCategory(
    name: '취업/기타',
    icon: Icons.work_outline_rounded,
    items: [
      _LicenseItem(id: 'ncs', name: 'NCS 직업기초능력', ready: false),
      _LicenseItem(id: 'korean_history', name: '한국사능력검정', subtitle: '심화 대비'),
    ],
  ),
];

/// 자격증 탭 — 이투스 "선생님" 메뉴처럼 상단 카테고리(전문자격사·IT·취업/기타) 선택 후
/// 하위 자격증 목록을 보여준다. 가맹거래사를 누르면 시험소개·시험과목·학습하기 메뉴로 이동한다.
class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  int _categoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final category = _categories[_categoryIndex];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text(
          '자격증',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          '분야를 선택하면 관련 자격증을 볼 수 있어요',
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(_categories.length, (i) {
            final selected = i == _categoryIndex;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == _categories.length - 1 ? 0 : 8),
                child: GestureDetector(
                  onTap: () => setState(() => _categoryIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: selected ? AppColors.primary : AppColors.glassBorder),
                    ),
                    child: Column(
                      children: [
                        Icon(_categories[i].icon, size: 20, color: selected ? Colors.white : AppColors.textMuted),
                        const SizedBox(height: 4),
                        Text(
                          _categories[i].name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: selected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        ...category.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _LicenseListTile(item: item),
          ),
        ),
      ],
    );
  }
}

class _LicenseListTile extends StatelessWidget {
  final _LicenseItem item;
  const _LicenseListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.035), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: item.ready
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CertificateMenuScreen(certId: item.id, certName: item.name)),
                  )
              : () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name}은(는) 준비 중이에요.')),
                  ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: item.ready ? AppColors.textPrimary : AppColors.textMuted,
                        ),
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle!,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ] else if (!item.ready) ...[
                        const SizedBox(height: 3),
                        const Text(
                          '준비 중입니다',
                          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                        ),
                      ],
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
