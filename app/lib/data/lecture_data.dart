/// 민법 특강 카드 데이터 — 홈 화면 가로 스크롤 그리드와 "더보기" 전체 그리드 화면이 공유한다.
class LectureItem {
  /// 표지 이미지가 아직 없는 특강(예: 경영학·경제법 특강)은 null — 이 경우 [styleKey]로
  /// subjectStyleOf에서 아이콘·색상을 가져와 아이콘형 카드로 대체 표시한다.
  final String? imageAsset;
  final String title;
  final List<String> keyPoints;
  final String subjectId;
  final String subjectName;
  final String category;

  /// 같은 category 안에서 더 세부적으로 필터링할 하위 유형(subTopic). 지정하지 않으면
  /// 해당 category 전체 문제를 보여준다.
  final String? subTopic;

  /// imageAsset이 없을 때 subjectStyleOf(styleKey)로 아이콘·색상을 조회하기 위한 키.
  final String? styleKey;

  const LectureItem({
    this.imageAsset,
    required this.title,
    required this.keyPoints,
    required this.subjectId,
    required this.subjectName,
    required this.category,
    this.subTopic,
    this.styleKey,
  });
}

const List<LectureItem> civilLawLectures = [
  LectureItem(
    imageAsset: 'assets/images/lecture_cover_civil_law.png',
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
  LectureItem(
    imageAsset: 'assets/images/lecture_cover_agency.png',
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
  LectureItem(
    imageAsset: 'assets/images/lecture_cover_declaration_of_intent.png',
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
  LectureItem(
    imageAsset: 'assets/images/lecture_cover_unfair_act.png',
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
  LectureItem(
    imageAsset: 'assets/images/lecture_cover_condition_period.png',
    title: '조건과 기한',
    keyPoints: [
      '조건 — 법률행위 효력의 발생·소멸을 장래의 불확실한 사실에 의존시키는 부관(정지조건·해제조건)',
      '조건성취의 효과 — 원칙적으로 소급효 없이 장래를 향해 발생하나, 당사자의 특약으로 소급효를 부여할 수 있음(제147조)',
      '조건성취의 방해·의제 — 신의칙에 반하여 조건 성취를 방해하거나 성취시킨 경우, 상대방은 조건이 성취(또는 불성취)한 것으로 주장 가능(제150조)',
      '조건에 친하지 않은 행위 — 혼인·이혼 등 신분행위와 상대방 지위를 불안정하게 하는 단독행위(상계 등)에는 원칙적으로 조건을 붙일 수 없음',
      '기한 — 도래가 확실한 장래 사실에 의존하는 부관(시기·종기, 확정기한·불확정기한)이며, 기한은 채무자의 이익을 위한 것으로 추정되고(제153조), 도래에는 소급효가 인정되지 않음',
    ],
    subjectId: 'civil_law',
    subjectName: '민법',
    category: '조건과 기한',
  ),
  LectureItem(
    imageAsset: 'assets/images/lecture_cover_concurrent_performance.png',
    title: '동시이행항변권',
    keyPoints: [
      '동시이행의 항변권(제536조) — 쌍무계약에서 대가관계 있는 채무 사이에 인정되는 연기적 항변권',
      '불안의 항변권(제536조 제2항) — 선이행의무자라도 상대방의 이행이 곤란할 현저한 사유가 있으면 이행 거절 가능',
      '효과 — 항변권이 있으면 이행지체책임이 발생하지 않고, 소송에서는 상환급부판결이 내려짐',
      '상계 제한 — 항변권이 붙은 채권을 자동채권으로 하는 상계는 원칙적으로 허용되지 않음',
      '준용 사례 — 계약해제로 인한 원상회복의무(제549조)에도 동시이행의 항변권 규정이 준용됨',
    ],
    subjectId: 'civil_law',
    subjectName: '민법',
    category: '동시이행항변권',
  ),
];

/// 한능검 특강 카드 데이터 — 시대별 그리드(고려/조선/근현대사). 이미지는 예전에 만들어둔 것을 재사용.
/// TODO: keyPoints는 우선 자리만 채워둔 상태 — 나중에 시대별 핵심 개념으로 교체.
const List<LectureItem> koreanHistoryLectures = [
  LectureItem(
    imageAsset: 'assets/images/lecture_cover_goryeo_history.png',
    title: '고려',
    keyPoints: ['추후 업데이트 예정'],
    subjectId: 'korean_history',
    subjectName: '한국사능력검정시험(심화)',
    category: '고려',
  ),
  LectureItem(
    imageAsset: 'assets/images/lecture_cover_joseon_history.png',
    title: '조선',
    keyPoints: ['추후 업데이트 예정'],
    subjectId: 'korean_history',
    subjectName: '한국사능력검정시험(심화)',
    category: '조선전기',
  ),
  LectureItem(
    imageAsset: 'assets/images/lecture_cover_modern_history.jpg',
    title: '근현대사',
    keyPoints: ['추후 업데이트 예정'],
    subjectId: 'korean_history',
    subjectName: '한국사능력검정시험(심화)',
    category: '일제강점기와 현대',
  ),
];

/// 경영학 특강 — 표지 이미지가 아직 없어 아이콘형 카드로 표시(styleKey로 아이콘·색상 지정).
/// 기출 분석상 비중이 높은 회계·마케팅 위주로 6개 선정.
const List<LectureItem> businessAdminLectures = [
  LectureItem(
    title: '재무제표의 이해',
    styleKey: 'ba_financial_statements',
    keyPoints: [
      '재무상태표는 특정 시점의 자산·부채·자본을, 포괄손익계산서는 일정 기간의 수익·비용을 나타낸다',
      '전체 재무제표는 재무상태표·포괄손익계산서·자본변동표·현금흐름표·주석 5가지로 구성된다',
      '회계정보의 질적 특성은 근본적 특성(목적적합성·표현충실성)과 보강적 특성(비교가능성·검증가능성·적시성·이해가능성)으로 나뉜다',
      '재무상태표는 유동성배열법에 따라 현금화가 빠른 자산부터 먼저 배열한다',
    ],
    subjectId: 'business_admin',
    subjectName: '경영학',
    category: '회계',
    subTopic: '재무제표의 이해',
  ),
  LectureItem(
    title: '재고자산과 매출원가',
    styleKey: 'ba_inventory',
    keyPoints: [
      '매출원가 = 기초재고액 + 당기매입액 − 기말재고액',
      '물가상승 시 매출총이익 크기는 후입선출법 < 이동평균법 < 선입선출법 순으로 나타난다',
      '저가법은 취득원가와 순실현가능가치 중 낮은 금액으로 재고자산을 평가하는 방법이다',
      '계속기록법과 실지재고조사법을 병행하면 재고자산감모손실을 파악할 수 있다',
    ],
    subjectId: 'business_admin',
    subjectName: '경영학',
    category: '회계',
    subTopic: '재고자산 평가와 매출원가',
  ),
  LectureItem(
    title: '시장세분화·표적시장·포지셔닝',
    styleKey: 'ba_stp',
    keyPoints: [
      'STP는 시장세분화(Segmentation) → 표적시장 선정(Targeting) → 포지셔닝(Positioning) 순으로 진행된다',
      '효과적인 시장세분화는 세분시장 내부는 동질적, 세분시장 간에는 이질적이어야 한다',
      '표적시장 선정전략에는 비차별적·차별적·집중적 마케팅이 있다',
      '포지셔닝은 소비자 지각·경쟁 환경 변화에 따라 재포지셔닝될 수 있다',
    ],
    subjectId: 'business_admin',
    subjectName: '경영학',
    category: '마케팅',
    subTopic: '시장세분화·표적시장·포지셔닝',
  ),
  LectureItem(
    title: '가격관리',
    styleKey: 'ba_pricing',
    keyPoints: [
      '신제품 가격전략에는 초기고가전략(스키밍)과 시장침투가격전략이 있다',
      '심리적 가격전략(단수가격·명성가격·준거가격)과 원가중심 가격결정(원가가산법)을 구분해야 한다',
      '가격차별은 세분시장이 분리되어 있고 재판매가 어려울 때 효과적으로 작동한다',
      '유보가격은 소비자가 지불할 용의가 있는 최고 가격을 의미한다',
    ],
    subjectId: 'business_admin',
    subjectName: '경영학',
    category: '마케팅',
    subTopic: '가격관리',
  ),
  LectureItem(
    title: '유통경로와 촉진전략',
    styleKey: 'ba_channel',
    keyPoints: [
      '유통경로 커버리지는 집중적·선택적·전속적 유통으로 구분되며, 프랜차이즈는 전속적 유통·계약형 VMS의 대표 사례이다',
      '수직적 마케팅시스템(VMS)은 기업형·계약형·관리형으로 나뉜다',
      '푸시전략(유통업자 대상)과 풀전략(최종소비자 대상)은 함께 병행되는 경우가 많다',
      '판매촉진은 단기 매출에, 광고는 장기 브랜드 구축에 효과적이다',
    ],
    subjectId: 'business_admin',
    subjectName: '경영학',
    category: '마케팅',
    subTopic: '유통경로와 촉진전략',
  ),
  LectureItem(
    title: '유형자산과 감가상각',
    styleKey: 'ba_ppe',
    keyPoints: [
      '유형자산 취득원가에는 설치비·시운전비 등이 포함되나, 취득 후 수선유지비(수익적 지출)는 제외된다',
      '정액법은 매기 동일한 금액을, 정률법은 초기에 크고 점차 감소하는 금액을 감가상각비로 인식한다',
      '자본적 지출을 수익적 지출로 잘못 처리하면 당기순이익이 과소계상된다',
      '내용연수가 비한정인 무형자산은 상각하지 않고 손상 여부만 검토한다',
    ],
    subjectId: 'business_admin',
    subjectName: '경영학',
    category: '회계',
    subTopic: '유형자산과 감가상각',
  ),
];

/// 경제법 특강 — 표지 이미지가 아직 없어 아이콘형 카드로 표시(styleKey로 아이콘·색상 지정).
/// 11개년 기출 비중 상위 + 가맹거래사 실무 연관성을 함께 고려해 6개 선정.
const List<LectureItem> economicLawLectures = [
  LectureItem(
    title: '시장지배적지위 남용',
    styleKey: 'el_dominant',
    keyPoints: [
      '11개년 기출 440문항 중 41문항으로 단일 챕터 최다 비중',
      '공정거래법 제5조는 남용행위를 가격 남용·출고조절·사업활동 방해·시장진입 방해·경쟁사업자 배제 등으로 유형화한다',
      '통상적인 정상 영업활동은 그 자체로 부당성이 인정되지 않아 남용행위에서 제외된다',
      '시장지배적사업자 추정 요건(시장점유율 등)도 함께 정리해두어야 한다',
    ],
    subjectId: 'economic_law',
    subjectName: '경제법',
    category: '시장지배적지위 남용',
  ),
  LectureItem(
    title: '자진신고자 감면(리니언시)',
    styleKey: 'el_leniency',
    keyPoints: [
      '담합에 가담한 사업자가 자진신고·조사협조를 하면 과징금·시정조치를 감면해주는 제도이다',
      '1순위 자진신고자는 과징금 전액 면제, 2순위는 일부 감경이 원칙이다',
      '자진신고 감면 제외 사유(반복 담합 등)와 감면 신청 순서·요건을 함께 정리해야 한다',
      '조사 착수 전/후 자진신고 여부에 따라 감면율이 달라질 수 있다',
    ],
    subjectId: 'economic_law',
    subjectName: '경제법',
    category: '자진신고자 감면',
  ),
  LectureItem(
    title: '거래상지위남용',
    styleKey: 'el_superior',
    keyPoints: [
      '불공정거래행위의 한 유형으로, 가맹본부-가맹점 관계처럼 거래상 지위 차이가 있는 관계에서 실무적으로 자주 문제된다',
      '구입강제·이익제공 강요·경영간섭·불이익제공 등이 대표적인 행위 유형이다',
      '시장지배적지위 남용과 달리 시장지배력이 없어도 성립할 수 있다는 점이 핵심 구별점이다',
      '거래상 지위의 판단은 상대방에 대한 거래의존도 등을 종합적으로 고려한다',
    ],
    subjectId: 'economic_law',
    subjectName: '경제법',
    category: '거래상지위남용',
  ),
  LectureItem(
    title: '과징금',
    styleKey: 'el_penalty',
    keyPoints: [
      '공정거래법 위반행위에 대해 부과하는 대표적인 행정제재 수단이다',
      '위반행위 유형별로 과징금 산정 기준(관련매출액 × 부과기준율)이 다르게 적용된다',
      '가중·감경 사유(자진시정, 조사협조, 반복 위반 등)를 함께 학습해야 한다',
      '과징금 부과와 별개로 시정조치·고발이 병과될 수 있다',
    ],
    subjectId: 'economic_law',
    subjectName: '경제법',
    category: '과징금',
  ),
  LectureItem(
    title: '불공정약관조항 무효사유',
    styleKey: 'el_clause',
    keyPoints: [
      '약관법상 신의성실 원칙에 반하여 공정을 잃은 약관조항은 무효이다',
      '면책조항·손해배상 예정조항·계약 해제·해지 조항 등 유형별 무효사유를 구분해서 학습해야 한다',
      '일반조항(제6조)과 개별 무효사유(제7조~제14조)의 관계를 함께 정리해야 한다',
      '약관법 관련 챕터 중 출제 비중이 가장 높은 주제이다',
    ],
    subjectId: 'economic_law',
    subjectName: '경제법',
    category: '불공정약관조항 무효사유',
  ),
  LectureItem(
    title: '재판매가격유지행위',
    styleKey: 'el_rpm',
    keyPoints: [
      '사업자가 거래상대방에게 자신이 정한 가격대로만 재판매하도록 강제하는 행위이다',
      '원칙적으로 금지되나, 저작물 등 일부 예외적으로 허용되는 경우가 있다',
      '최고가격 유지행위와 최저가격 유지행위는 위법성 판단이 다르게 취급된다',
      '가맹사업 거래에서 가맹본부의 가격 통제와 관련해 실무적으로도 자주 논의되는 주제이다',
    ],
    subjectId: 'economic_law',
    subjectName: '경제법',
    category: '재판매가격유지행위',
  ),
];
