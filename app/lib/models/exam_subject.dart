/// 가맹거래사 1차 시험 과목 구조
class ExamSubject {
  final String id;
  final String name;
  final List<String> categories;

  const ExamSubject({
    required this.id,
    required this.name,
    required this.categories,
  });
}

const List<ExamSubject> examSubjects = [
  ExamSubject(
    id: 'economic_law',
    name: '경제법',
    categories: ['공정거래법', '약관법'],
  ),
  ExamSubject(
    id: 'civil_law',
    name: '민법',
    categories: ['민법총칙', '물권법', '채권법'],
  ),
  ExamSubject(
    id: 'business_admin',
    name: '경영학',
    categories: ['회계', '재무관리', '마케팅', '조직행동·인사관리', '생산관리', '경영정보시스템'],
  ),
];
