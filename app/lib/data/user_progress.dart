import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// 챕터(카테고리)별 정답률 집계 결과 — 학습 리포트의 취약 챕터 계산에 쓰인다.
class WeakCategoryStat {
  final String subjectId;
  final String subjectName;
  final String category;
  final double accuracy;

  const WeakCategoryStat({
    required this.subjectId,
    required this.subjectName,
    required this.category,
    required this.accuracy,
  });
}

String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// 오답노트 / 단권화 / 학습 통계(시간·정답수·취약챕터)를 기억하는 저장소.
/// 로그인(이메일 계정)한 사용자는 Firestore(`users/{uid}`)에도 저장되어 기기를 바꿔도
/// 이어진다. 로그인 전(게스트)에는 앱을 실행하는 동안만 메모리에 남는다.
class UserProgress extends ChangeNotifier {
  UserProgress._();
  static final UserProgress instance = UserProgress._();

  final Set<String> _wrongQuestionIds = {};
  final Set<String> _compiledQuestionIds = {};

  int totalSolved = 0;
  int totalCorrect = 0;
  int totalStudySeconds = 0;
  int streakDays = 0;
  String? _lastStudyDate;

  int _todaySolved = 0;
  int _todayStudySeconds = 0;
  DateTime? _today;

  final Map<String, int> _categoryAttempts = {};
  final Map<String, int> _categoryWrong = {};
  final Map<String, String> _categorySubjectId = {};
  final Map<String, String> _categorySubjectName = {};

  /// 날짜(yyyy-MM-dd) → 그날 학습한 분 — 최근 7일 그래프용. 로그인 사용자는 클라우드에서
  /// 불러오고, 오늘 학습분은 로컬에서 즉시 반영한다.
  final Map<String, int> _dailyMinutes = {};

  String? _uid;

  List<String> get wrongQuestionIds => _wrongQuestionIds.toList(growable: false);
  List<String> get compiledQuestionIds => _compiledQuestionIds.toList(growable: false);

  bool isWrong(String questionId) => _wrongQuestionIds.contains(questionId);
  bool isCompiled(String questionId) => _compiledQuestionIds.contains(questionId);

  int minutesOn(DateTime day) => _dailyMinutes[_dateKey(day)] ?? 0;

  void markWrong(String questionId) {
    if (_wrongQuestionIds.add(questionId)) notifyListeners();
  }

  /// 오답노트에서 다시 맞히면 목록에서 제거한다.
  void markCorrect(String questionId) {
    if (_wrongQuestionIds.remove(questionId)) notifyListeners();
  }

  void removeWrong(String questionId) {
    if (_wrongQuestionIds.remove(questionId)) notifyListeners();
  }

  void toggleCompiled(String questionId) {
    if (!_compiledQuestionIds.remove(questionId)) {
      _compiledQuestionIds.add(questionId);
    }
    notifyListeners();
  }

  void removeCompiled(String questionId) {
    if (_compiledQuestionIds.remove(questionId)) notifyListeners();
  }

  void _rolloverIfNeeded() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_today == null || _today != today) {
      _today = today;
      _todaySolved = 0;
      _todayStudySeconds = 0;
    }
  }

  int get todaySolved {
    _rolloverIfNeeded();
    return _todaySolved;
  }

  int get todayStudySeconds {
    _rolloverIfNeeded();
    return _todayStudySeconds;
  }

  double get totalAccuracy => totalSolved == 0 ? 0 : totalCorrect / totalSolved;

  /// 로그인 상태가 바뀔 때(로그인/로그아웃/앱 시작) 호출한다. uid가 있으면 Firestore에
  /// 저장된 학습 기록을 불러와 화면에 반영하고, 이후 기록은 클라우드에도 동기화된다.
  Future<void> attachUser(String? uid) async {
    _uid = uid;
    if (uid == null) {
      // 로그아웃 — 방금 로그인했던 계정 데이터가 게스트 화면에 남아있지 않도록 초기화한다.
      totalSolved = 0;
      totalCorrect = 0;
      totalStudySeconds = 0;
      streakDays = 0;
      _lastStudyDate = null;
      _categoryAttempts.clear();
      _categoryWrong.clear();
      _categorySubjectId.clear();
      _categorySubjectName.clear();
      _dailyMinutes.clear();
      _todaySolved = 0;
      _todayStudySeconds = 0;
      _today = null;
      notifyListeners();
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data == null) {
        // 첫 로그인(가입 직후) — 지금까지의 게스트 기록을 그대로 클라우드에 올린다.
        await _pushFullSnapshot();
        return;
      }
      totalSolved = (data['totalSolved'] as num?)?.toInt() ?? totalSolved;
      totalCorrect = (data['totalCorrect'] as num?)?.toInt() ?? totalCorrect;
      totalStudySeconds = (data['totalStudySeconds'] as num?)?.toInt() ?? totalStudySeconds;
      streakDays = (data['streakDays'] as num?)?.toInt() ?? streakDays;
      _lastStudyDate = data['lastStudyDate'] as String? ?? _lastStudyDate;
      _mergeStringIntMap(data['categoryAttempts'], _categoryAttempts);
      _mergeStringIntMap(data['categoryWrong'], _categoryWrong);
      _mergeStringStringMap(data['categorySubjectId'], _categorySubjectId);
      _mergeStringStringMap(data['categorySubjectName'], _categorySubjectName);

      final now = DateTime.now();
      final dailySnaps = await Future.wait(List.generate(7, (i) {
        final day = now.subtract(Duration(days: i));
        return FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('daily')
            .doc(_dateKey(day))
            .get();
      }));
      for (final snap in dailySnaps) {
        final seconds = (snap.data()?['studySeconds'] as num?)?.toInt() ?? 0;
        if (seconds > 0) _dailyMinutes[snap.id] = seconds ~/ 60;
      }
      notifyListeners();
    } catch (_) {
      // 오프라인이거나 Firestore 접근이 안 되는 환경에서는 로컬 기록만 유지한다.
    }
  }

  void _mergeStringIntMap(dynamic raw, Map<String, int> target) {
    if (raw is! Map) return;
    raw.forEach((k, v) => target[k as String] = (v as num).toInt());
  }

  void _mergeStringStringMap(dynamic raw, Map<String, String> target) {
    if (raw is! Map) return;
    raw.forEach((k, v) => target[k as String] = v as String);
  }

  Future<void> _pushFullSnapshot() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'totalSolved': totalSolved,
        'totalCorrect': totalCorrect,
        'totalStudySeconds': totalStudySeconds,
        'streakDays': streakDays,
        'lastStudyDate': _lastStudyDate,
        'categoryAttempts': _categoryAttempts,
        'categoryWrong': _categoryWrong,
        'categorySubjectId': _categorySubjectId,
        'categorySubjectName': _categorySubjectName,
      }, SetOptions(merge: true));
    } catch (_) {
      // 무시 — 다음 문제풀이 때 다시 동기화 시도된다.
    }
  }

  void _updateStreak(String today) {
    if (_lastStudyDate == today) return;
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    streakDays = (_lastStudyDate == yesterday) ? streakDays + 1 : 1;
    _lastStudyDate = today;
  }

  /// 문제 1개를 채점할 때마다 호출 — 누적/오늘 통계와 챕터별 정답률 집계에 반영한다.
  void recordAnswer({
    required String subjectId,
    required String subjectName,
    required String category,
    required bool correct,
  }) {
    _rolloverIfNeeded();
    totalSolved++;
    _todaySolved++;
    if (correct) totalCorrect++;

    _categoryAttempts[category] = (_categoryAttempts[category] ?? 0) + 1;
    _categorySubjectId[category] = subjectId;
    _categorySubjectName[category] = subjectName;
    if (!correct) {
      _categoryWrong[category] = (_categoryWrong[category] ?? 0) + 1;
    }

    final today = _dateKey(DateTime.now());
    _updateStreak(today);
    notifyListeners();

    final uid = _uid;
    if (uid == null) return;
    final usersRef = FirebaseFirestore.instance.collection('users').doc(uid);
    usersRef.set({
      'totalSolved': FieldValue.increment(1),
      'totalCorrect': FieldValue.increment(correct ? 1 : 0),
      'streakDays': streakDays,
      'lastStudyDate': _lastStudyDate,
      'categoryAttempts': {category: FieldValue.increment(1)},
      'categoryWrong': {category: FieldValue.increment(correct ? 0 : 1)},
      'categorySubjectId': {category: subjectId},
      'categorySubjectName': {category: subjectName},
    }, SetOptions(merge: true)).catchError((_) {});
    usersRef.collection('daily').doc(today).set({
      'solved': FieldValue.increment(1),
    }, SetOptions(merge: true)).catchError((_) {});
  }

  /// 문제풀이 화면에 머문 시간(초)을 학습시간에 누적한다.
  void addStudySeconds(int seconds) {
    if (seconds <= 0) return;
    _rolloverIfNeeded();
    totalStudySeconds += seconds;
    _todayStudySeconds += seconds;

    final today = _dateKey(DateTime.now());
    _dailyMinutes[today] = (_dailyMinutes[today] ?? 0) + seconds ~/ 60;
    notifyListeners();

    final uid = _uid;
    if (uid == null) return;
    final usersRef = FirebaseFirestore.instance.collection('users').doc(uid);
    usersRef.set({'totalStudySeconds': FieldValue.increment(seconds)}, SetOptions(merge: true)).catchError((_) {});
    usersRef.collection('daily').doc(today).set({
      'studySeconds': FieldValue.increment(seconds),
    }, SetOptions(merge: true)).catchError((_) {});
  }

  /// 정답률이 낮은 챕터부터 정렬해서 반환 — 시도 횟수가 [minAttempts] 미만이면 신뢰도가 낮아 제외한다.
  List<WeakCategoryStat> weakestCategories({int limit = 3, int minAttempts = 3}) {
    final stats = _categoryAttempts.entries
        .where((e) => e.value >= minAttempts)
        .map((e) {
          final wrong = _categoryWrong[e.key] ?? 0;
          return WeakCategoryStat(
            subjectId: _categorySubjectId[e.key] ?? '',
            subjectName: _categorySubjectName[e.key] ?? '',
            category: e.key,
            accuracy: 1 - wrong / e.value,
          );
        })
        .toList()
      ..sort((a, b) => a.accuracy.compareTo(b.accuracy));
    return stats.take(limit).toList();
  }
}
