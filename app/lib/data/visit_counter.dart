import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// 방문 수 — Firestore에 두 가지를 기록한다.
/// - `stats/visits`의 count: 앱을 켤 때마다 1씩 늘어나는 누적 방문 횟수.
/// - `stats/visits/daily/{yyyy-MM-dd}`의 count: 오늘 하루치 방문 횟수(자정 지나면 새 문서로 자연히 리셋).
/// 로그인 여부와 무관하게 새로고침·재방문마다 카운트되므로 "순 방문자 수"가 아니라
/// "누적/오늘 방문 횟수"에 가깝다.
class VisitCounter extends ChangeNotifier {
  VisitCounter._();
  static final VisitCounter instance = VisitCounter._();

  int? _total;
  int? _today;
  int? get total => _total;
  int? get today => _today;

  Future<void> recordVisit() async {
    try {
      final now = DateTime.now();
      final dateKey =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final totalRef = FirebaseFirestore.instance.collection('stats').doc('visits');
      final dailyRef = totalRef.collection('daily').doc(dateKey);

      await Future.wait([
        totalRef.set({'count': FieldValue.increment(1)}, SetOptions(merge: true)),
        dailyRef.set({'count': FieldValue.increment(1)}, SetOptions(merge: true)),
      ]);
      final results = await Future.wait([totalRef.get(), dailyRef.get()]);
      _total = (results[0].data()?['count'] as num?)?.toInt();
      _today = (results[1].data()?['count'] as num?)?.toInt();
      notifyListeners();
    } catch (_) {
      // Firebase가 초기화되지 않은 환경(예: 위젯 테스트)에서는 조용히 무시한다.
    }
  }
}
