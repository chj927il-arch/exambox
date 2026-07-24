/// 과목별 출제 유형(챕터) 통계.
/// topic 문자열은 [sample_questions.dart]의 Question.category 값과 동일하게 맞춰
/// 챕터 선택 시 해당 카테고리의 문제만 필터링해서 보여줄 수 있도록 한다.
class TopicStat {
  final String topic;
  final int questionCount;
  final int totalQuestions;

  const TopicStat({
    required this.topic,
    required this.questionCount,
    required this.totalQuestions,
  });

  double get ratio => totalQuestions == 0 ? 0 : questionCount / totalQuestions;
}

/// 경제법 — 2016~2026년(제15회~제24회) 기출 440문항 직접 분석 결과.
/// 대분류 안에서도 실제 학습에 도움이 되도록 세부 유형(챕터)까지 나눠서 정리했다.
/// (세부 배분은 대분류 실측치를 기준으로 한 추정치이며, 총합은 대분류 합계와 일치)
const List<TopicStat> economicLawTopicStats = [
  // 약관법 (대분류 합계 111문항)
  TopicStat(topic: '불공정약관조항 무효사유', questionCount: 25, totalQuestions: 440),
  TopicStat(topic: '약관 명시·설명의무', questionCount: 22, totalQuestions: 440),
  TopicStat(topic: '약관 해석·총칙', questionCount: 20, totalQuestions: 440),
  TopicStat(topic: '약관분쟁조정협의회', questionCount: 17, totalQuestions: 440),
  TopicStat(topic: '표준약관', questionCount: 15, totalQuestions: 440),
  TopicStat(topic: '약관 심사·시정절차', questionCount: 12, totalQuestions: 440),

  // 공정위 조직·절차 (대분류 합계 102문항)
  TopicStat(topic: '과징금', questionCount: 22, totalQuestions: 440),
  TopicStat(topic: '조사절차', questionCount: 18, totalQuestions: 440),
  TopicStat(topic: '분쟁조정협의회(공정거래)', questionCount: 16, totalQuestions: 440),
  TopicStat(topic: '동의의결', questionCount: 12, totalQuestions: 440),
  TopicStat(topic: '위원회 구성·회의', questionCount: 10, totalQuestions: 440),
  TopicStat(topic: '손해배상책임', questionCount: 10, totalQuestions: 440),
  TopicStat(topic: '고발', questionCount: 8, totalQuestions: 440),
  TopicStat(topic: '이의신청·불복절차', questionCount: 6, totalQuestions: 440),

  // 시장지배적지위 남용 (41문항, 세분화 없음)
  TopicStat(topic: '시장지배적지위 남용', questionCount: 41, totalQuestions: 440),

  // 부당한 공동행위 (대분류 합계 46문항)
  TopicStat(topic: '담합의 성립요건', questionCount: 16, totalQuestions: 440),
  TopicStat(topic: '자진신고자 감면', questionCount: 14, totalQuestions: 440),
  TopicStat(topic: '공동행위 인가제도', questionCount: 10, totalQuestions: 440),
  TopicStat(topic: '부당공동행위 유형', questionCount: 6, totalQuestions: 440),

  // 목적·총칙 (33문항, 세분화 없음)
  TopicStat(topic: '목적·총칙', questionCount: 33, totalQuestions: 440),

  // 불공정거래행위 (대분류 합계 59문항)
  TopicStat(topic: '거래상지위남용', questionCount: 14, totalQuestions: 440),
  TopicStat(topic: '부당지원행위', questionCount: 10, totalQuestions: 440),
  TopicStat(topic: '구속조건부거래', questionCount: 9, totalQuestions: 440),
  TopicStat(topic: '부당염매·경쟁사업자배제', questionCount: 9, totalQuestions: 440),
  TopicStat(topic: '사업활동방해', questionCount: 9, totalQuestions: 440),
  TopicStat(topic: '거래거절', questionCount: 8, totalQuestions: 440),

  // 사업자단체 금지행위 (25문항, 세분화 없음)
  TopicStat(topic: '사업자단체 금지행위', questionCount: 25, totalQuestions: 440),

  // 재판매가격유지행위 (16문항, 세분화 없음)
  TopicStat(topic: '재판매가격유지행위', questionCount: 16, totalQuestions: 440),

  // 특수관계인 부당이익제공 (7문항, 세분화 없음)
  TopicStat(topic: '특수관계인 부당이익제공', questionCount: 7, totalQuestions: 440),

  // 경제력집중 억제 (1문항, 세분화 없음)
  TopicStat(topic: '경제력집중 억제', questionCount: 1, totalQuestions: 440),
];

/// 민법 · 경영학은 기출 유형 분석이 아직 진행되지 않아, 과목 구조상의
/// 대분류를 챕터로 우선 노출한다 (추후 기출 분석 완료 시 실제 비중으로 교체 예정).
const List<TopicStat> civilLawTopicStats = [
  TopicStat(topic: '채권법', questionCount: 0, totalQuestions: 0),
  TopicStat(topic: '물권법', questionCount: 0, totalQuestions: 0),
  TopicStat(topic: '민법총칙', questionCount: 0, totalQuestions: 0),
];

const List<TopicStat> businessAdminTopicStats = [
  TopicStat(topic: '재무관리', questionCount: 0, totalQuestions: 0),
  TopicStat(topic: '마케팅', questionCount: 0, totalQuestions: 0),
  TopicStat(topic: '조직행동', questionCount: 0, totalQuestions: 0),
  TopicStat(topic: '생산관리', questionCount: 0, totalQuestions: 0),
];

/// 한국사능력검정시험(심화) — 시대별 6구간 출제 비중.
/// 매 회차 50문항이 대체로 시대순으로 출제되는 점에 착안해, 일반적으로 알려진
/// 심화 등급 출제 비중(선사~현대)을 시대별로 구간화한 추정치이다(추후 회차별 실측 반영 예정).
const List<TopicStat> koreanHistoryTopicStats = [
  TopicStat(topic: '일제강점기와 현대', questionCount: 11, totalQuestions: 50),
  TopicStat(topic: '조선전기', questionCount: 8, totalQuestions: 50),
  TopicStat(topic: '조선후기', questionCount: 8, totalQuestions: 50),
  TopicStat(topic: '고려', questionCount: 8, totalQuestions: 50),
  TopicStat(topic: '선사·고대', questionCount: 8, totalQuestions: 50),
  TopicStat(topic: '근대(개항기)', questionCount: 7, totalQuestions: 50),
];

/// 이 과목의 챕터(유형) 통계가 실제 기출 분석 기반인지 여부.
const Map<String, bool> subjectStatsIsAnalyzed = {
  'economic_law': true,
  'civil_law': false,
  'business_admin': false,
  'korean_history': true,
};

List<TopicStat> chapterStatsFor(String subjectId) {
  switch (subjectId) {
    case 'economic_law':
      final sorted = [...economicLawTopicStats]..sort((a, b) => b.questionCount.compareTo(a.questionCount));
      return sorted;
    case 'civil_law':
      return civilLawTopicStats;
    case 'business_admin':
      return businessAdminTopicStats;
    case 'korean_history':
      return koreanHistoryTopicStats;
    default:
      return const [];
  }
}
