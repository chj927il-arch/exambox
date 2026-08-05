import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// 누적 방문 수(페이지 로드 횟수) — Firestore(`stats/visits` 문서 하나)의 count 필드를
/// 앱을 켤 때마다 1씩 늘리고, 그 값을 홈 화면에 보여준다. 로그인 여부와 무관하게
/// 새로고침·재방문마다 카운트되므로 "순 방문자 수"가 아니라 "누적 방문 횟수"에 가깝다.
class VisitCounter extends ChangeNotifier {
  VisitCounter._();
  static final VisitCounter instance = VisitCounter._();

  int? _count;
  int? get count => _count;

  Future<void> recordVisit() async {
    try {
      final ref = FirebaseFirestore.instance.collection('stats').doc('visits');
      await ref.set({'count': FieldValue.increment(1)}, SetOptions(merge: true));
      final snapshot = await ref.get();
      _count = (snapshot.data()?['count'] as num?)?.toInt();
      notifyListeners();
    } catch (_) {
      // Firebase가 초기화되지 않은 환경(예: 위젯 테스트)에서는 조용히 무시한다.
    }
  }
}
