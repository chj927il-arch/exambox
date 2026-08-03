import 'user_progress.dart';

/// 학습 이력 목업 데이터 (실 학습 데이터 연동 전, 홈 대시보드 확인용)
class DailyActivity {
  final String label; // 요일
  final int minutes;

  const DailyActivity({required this.label, required this.minutes});
}

class StudyStats {
  // 연속 학습일·주간활동 그래프는 날짜별 이력 저장이 아직 없어(로그인·서버 저장 붙기 전)
  // 실제 값 대신 초기 상태(0)로 둔다. 로그인 기능 붙을 때 실제 값으로 교체 예정.
  static const int streakDays = 0;
  static const int todayGoal = 20;

  static int get todaySolved => UserProgress.instance.todaySolved;
  static int get todayMinutes => UserProgress.instance.todayStudySeconds ~/ 60;

  static int get totalSolved => UserProgress.instance.totalSolved;
  static int get totalMinutes => UserProgress.instance.totalStudySeconds ~/ 60;
  static double get totalAccuracy => UserProgress.instance.totalAccuracy;

  static const List<String> _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  /// 최근 7일 학습 시간(분) — 과거 → 오늘 순서. 날짜별 이력 저장이 아직 없어
  /// 오늘 이전 6일은 0으로 초기화하고, 오늘 칸만 실제 todayMinutes로 채운다.
  static List<DailyActivity> get weeklyActivity {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final daysAgo = 6 - i;
      final label = _weekdayLabels[(now.weekday - 1 - daysAgo) % 7];
      return DailyActivity(label: label, minutes: daysAgo == 0 ? todayMinutes : 0);
    });
  }

  static String get totalHoursLabel {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return m == 0 ? '$h시간' : '$h시간 $m분';
  }
}

/// 과목별 학습 진행률(0.0~1.0) — 과목별 문제 수 집계가 아직 없어 초기 상태(0)로 둔다.
const Map<String, double> mockSubjectProgress = {
  'economic_law': 0.0,
  'civil_law': 0.0,
  'business_admin': 0.0,
};

/// 과목별 오늘 푼 문제 수 — 과목별 일일 집계가 아직 없어 초기 상태(0)로 둔다.
const Map<String, int> mockSubjectTodaySolved = {
  'economic_law': 0,
  'civil_law': 0,
  'business_admin': 0,
};

/// 학습 리포트용 — 과목별 가장 취약한 챕터.
class WeakChapter {
  final String subjectId;
  final String subjectName;
  final String chapterName;
  final double accuracy; // 0.0 ~ 1.0
  final String advice;

  const WeakChapter({
    required this.subjectId,
    required this.subjectName,
    required this.chapterName,
    required this.accuracy,
    required this.advice,
  });
}

String _adviceFor(double accuracy) {
  if (accuracy < 0.5) return '정답률이 낮은 편이에요. 관련 개념부터 차근차근 다시 정리해보세요.';
  if (accuracy < 0.7) return '조금 더 반복하면 확실히 잡을 수 있어요. 틀린 문제 위주로 복습해보세요.';
  return '거의 다 왔어요! 헷갈렸던 부분만 한 번 더 짚어보세요.';
}

/// 실제 풀이 기록 기반 취약 챕터 — 시도 횟수가 충분히 쌓인 챕터가 없으면 빈 목록을 반환한다.
List<WeakChapter> computeWeakChapters({int limit = 3, int minAttempts = 3}) {
  return UserProgress.instance
      .weakestCategories(limit: limit, minAttempts: minAttempts)
      .map((s) => WeakChapter(
            subjectId: s.subjectId,
            subjectName: s.subjectName,
            chapterName: s.category,
            accuracy: s.accuracy,
            advice: _adviceFor(s.accuracy),
          ))
      .toList();
}
