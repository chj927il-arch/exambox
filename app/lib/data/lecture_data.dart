/// 민법 특강 카드 데이터 — 홈 화면 가로 스크롤 그리드와 "더보기" 전체 그리드 화면이 공유한다.
class LectureItem {
  final String imageAsset;
  final String title;
  final List<String> keyPoints;
  final String subjectId;
  final String subjectName;
  final String category;

  const LectureItem({
    required this.imageAsset,
    required this.title,
    required this.keyPoints,
    required this.subjectId,
    required this.subjectName,
    required this.category,
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
    keyPoints: ['추후 업데이트 예정'],
    subjectId: 'civil_law',
    subjectName: '민법',
    category: '동시이행항변권',
  ),
];
