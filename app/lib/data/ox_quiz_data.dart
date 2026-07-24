class OxQuestion {
  final String subjectId;
  final String subjectName;
  final String statement;
  final bool answer;
  final String explanation;

  const OxQuestion({
    required this.subjectId,
    required this.subjectName,
    required this.statement,
    required this.answer,
    required this.explanation,
  });
}

class DailyOxQuiz {
  final String date;
  final List<OxQuestion> questions;

  const DailyOxQuiz({required this.date, required this.questions});
}

const dailyOxQuizzes = [
  DailyOxQuiz(
    date: '2026-07-25',
    questions: [
      OxQuestion(
        subjectId: 'economic_law',
        subjectName: '경제법',
        statement: '공정거래위원회 위원의 임기는 3년이며 1차에 한하여 연임할 수 있다.',
        answer: true,
        explanation: '공정거래위원회 위원(위원장·부위원장 포함)의 임기는 3년이며, 1차에 한하여 연임할 수 있습니다.',
      ),
      OxQuestion(
        subjectId: 'civil_law',
        subjectName: '민법',
        statement: '저당권은 목적물의 점유를 채권자에게 이전해야만 성립하는 담보물권이다.',
        answer: false,
        explanation: '저당권은 점유를 이전하지 않는 비점유 담보물권입니다. 점유를 이전해야 하는 것은 질권입니다.',
      ),
      OxQuestion(
        subjectId: 'business_admin',
        subjectName: '경영학',
        statement: '마케팅믹스의 4P는 제품, 가격, 유통, 촉진으로 구성된다.',
        answer: true,
        explanation: '4P는 Product(제품), Price(가격), Place(유통), Promotion(촉진)으로 구성됩니다.',
      ),
      OxQuestion(
        subjectId: 'korean_history',
        subjectName: '한국사',
        statement: '고인돌은 청동기 시대 지배층의 무덤으로, 계급 사회의 모습을 보여 준다.',
        answer: true,
        explanation: '고인돌은 거대한 돌을 옮기려면 많은 인력이 필요했기 때문에, 이를 주도할 수 있었던 지배층의 권력과 계급 사회의 성립을 보여 주는 유적입니다.',
      ),
    ],
  ),
  DailyOxQuiz(
    date: '2026-07-17',
    questions: [
      OxQuestion(
        subjectId: 'economic_law',
        subjectName: '경제법',
        statement: '시장지배적사업자의 추정에는 매출액뿐 아니라 시장점유율도 함께 고려된다.',
        answer: true,
        explanation: '공정거래법상 시장지배적사업자 추정은 시장점유율을 기준으로 하며, 1개 사업자 50% 이상 또는 3개 이하 사업자 합계 75% 이상인 경우 등이 해당됩니다.',
      ),
      OxQuestion(
        subjectId: 'civil_law',
        subjectName: '민법',
        statement: '미성년자가 법정대리인의 동의 없이 한 법률행위는 무효이다.',
        answer: false,
        explanation: '무효가 아니라 취소할 수 있는 법률행위입니다. 취소되기 전까지는 유효합니다.',
      ),
      OxQuestion(
        subjectId: 'business_admin',
        subjectName: '경영학',
        statement: '손익분기점은 총수익과 총비용이 일치하는 판매량을 의미한다.',
        answer: true,
        explanation: '손익분기점(BEP)은 이익이 0이 되는 지점, 즉 총수익=총비용이 되는 판매량(또는 매출액)입니다.',
      ),
    ],
  ),
  DailyOxQuiz(
    date: '2026-07-16',
    questions: [
      OxQuestion(
        subjectId: 'economic_law',
        subjectName: '경제법',
        statement: '약관의 뜻이 명확하지 않은 경우 고객에게 유리하게 해석해야 한다.',
        answer: true,
        explanation: '약관법상 작성자 불이익의 원칙(불명확조항 해석의 원칙)에 따라 고객에게 유리하게 해석합니다.',
      ),
      OxQuestion(
        subjectId: 'civil_law',
        subjectName: '민법',
        statement: '점유는 물건에 대한 사실상의 지배만으로는 인정되지 않고 등기가 필요하다.',
        answer: false,
        explanation: '점유는 등기와 무관하게 물건에 대한 사실상의 지배가 있으면 인정되는 사실행위입니다.',
      ),
      OxQuestion(
        subjectId: 'business_admin',
        subjectName: '경영학',
        statement: '마케팅믹스의 4P는 제품, 가격, 유통, 촉진을 의미한다.',
        answer: true,
        explanation: '4P는 Product, Price, Place, Promotion으로 구성됩니다.',
      ),
    ],
  ),
  DailyOxQuiz(
    date: '2026-07-15',
    questions: [
      OxQuestion(
        subjectId: 'economic_law',
        subjectName: '경제법',
        statement: '부당한 공동행위는 사업자 간 명시적 합의가 있어야만 성립한다.',
        answer: false,
        explanation: '묵시적 합의나 정황증거에 의한 합의 추정만으로도 부당한 공동행위가 성립할 수 있습니다.',
      ),
      OxQuestion(
        subjectId: 'civil_law',
        subjectName: '민법',
        statement: '채무불이행으로 인한 손해배상은 원칙적으로 통상손해를 그 한도로 한다.',
        answer: true,
        explanation: '민법 제393조에 따라 통상손해가 원칙이며, 특별손해는 채무자가 알았거나 알 수 있었을 경우에 한해 배상 범위에 포함됩니다.',
      ),
      OxQuestion(
        subjectId: 'business_admin',
        subjectName: '경영학',
        statement: '조직행동론에서 허츠버그의 2요인이론은 위생요인과 동기요인으로 구성된다.',
        answer: true,
        explanation: '허츠버그의 2요인이론은 불만족과 관련된 위생요인, 만족과 관련된 동기요인으로 구분됩니다.',
      ),
    ],
  ),
  DailyOxQuiz(
    date: '2026-07-14',
    questions: [
      OxQuestion(
        subjectId: 'economic_law',
        subjectName: '경제법',
        statement: '공정거래위원회의 처분에 불복하려면 처분일로부터 30일 이내에 이의신청할 수 있다.',
        answer: true,
        explanation: '공정거래법상 처분 고지를 받은 날로부터 30일 이내에 공정거래위원회에 이의신청이 가능합니다.',
      ),
      OxQuestion(
        subjectId: 'civil_law',
        subjectName: '민법',
        statement: '저당권은 목적물의 점유를 이전하지 않고 설정할 수 있는 담보물권이다.',
        answer: true,
        explanation: '저당권은 점유를 이전하지 않는 비점유 담보물권이라는 점에서 질권과 구별됩니다.',
      ),
      OxQuestion(
        subjectId: 'business_admin',
        subjectName: '경영학',
        statement: '재무관리에서 자기자본비용은 부채비용보다 항상 낮다.',
        answer: false,
        explanation: '주주는 채권자보다 후순위 위험을 부담하므로 일반적으로 자기자본비용이 부채비용보다 높습니다.',
      ),
    ],
  ),
];
