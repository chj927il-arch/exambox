import 'package:flutter/material.dart';
import '../data/comments_store.dart';
import '../data/likes_store.dart';
import '../data/study_stats.dart';
import '../data/user_progress.dart';
import '../models/exam_subject.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/subject_style.dart';
import '../widgets/glass_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/weak_chapter_row.dart';
import 'login_screen.dart';
import 'subject_chapters_screen.dart';
import 'wrong_note_screen.dart';

/// 마이페이지 탭 — 학습리포트 전체 + 오답노트 바로가기.
/// 학습시간·정답수·취약챕터는 UserProgress(실제 풀이 기록)를 그대로 반영하므로
/// 문제를 풀 때마다 값이 바뀔 수 있어 ListenableBuilder로 감싼다.
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([UserProgress.instance, AuthService.instance]),
      builder: (context, _) {
        final weakChapters = computeWeakChapters();
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 16),
            const _TodayGoalCard(),
            const SizedBox(height: 20),
            const Text(
              '학습 리포트',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            const _StatsGrid(),
            const SizedBox(height: 16),
            const _WeeklyActivityCard(),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('과목별 취약 챕터', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('정답률이 낮은 챕터부터 먼저 보강해보세요', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  if (weakChapters.isEmpty)
                    const Text(
                      '아직 데이터가 충분하지 않아요. 문제를 몇 개 더 풀어보면\n취약한 챕터를 분석해서 보여드릴게요.',
                      style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500, height: 1.5),
                    )
                  else
                    ...List.generate(weakChapters.length, (i) {
                      final isLast = i == weakChapters.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                        child: WeakChapterRow(chapter: weakChapters[i]),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '과목별 학습 현황',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            ...examSubjects.map(
              (subject) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SubjectProgressCard(subject: subject),
              ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.error_outline_rounded,
                    label: '오답노트',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WrongNoteScreen())),
                  ),
                  if (AuthService.instance.isLoggedIn) ...[
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.logout_rounded,
                      label: '로그아웃',
                      onTap: () async {
                        await AuthService.instance.signOut();
                        final uid = AuthService.instance.currentUser?.uid;
                        LikesStore.instance.setUid(uid);
                        CommentsStore.instance.setUid(uid);
                        await UserProgress.instance.attachUser(null);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.instance.isLoggedIn;
    final email = AuthService.instance.currentUser?.email;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, Color(0xFF2A2D35)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? (email ?? '수험생님, 환영해요 👋') : '수험생님, 환영해요 👋',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  isLoggedIn ? '학습 기록이 안전하게 저장되고 있어요' : '로그인하면 학습 기록이 저장돼요',
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (!isLoggedIn)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                foregroundColor: AppColors.ink,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text('로그인', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

class _TodayGoalCard extends StatelessWidget {
  const _TodayGoalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, Color(0xFF2A2D35)],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: 0.22), blurRadius: 22, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  '오늘도 한 문제 더\n풀어볼까요?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),
              _StreakBadge(days: StudyStats.streakDays),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: StudyStats.todaySolved / StudyStats.todayGoal,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              valueColor: const AlwaysStoppedAnimation(AppColors.accentGold),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '오늘 목표 ${StudyStats.todaySolved} / ${StudyStats.todayGoal}문제 · ${StudyStats.todayMinutes}분 학습',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int days;
  const _StreakBadge({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 4),
          Text('$days일', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    final stats = [
      (icon: Icons.schedule_rounded, label: '누적 학습시간', value: StudyStats.totalHoursLabel),
      (icon: Icons.local_fire_department_rounded, label: '연속 학습일', value: '${StudyStats.streakDays}일'),
      (icon: Icons.task_alt_rounded, label: '누적 푼 문제', value: '${StudyStats.totalSolved}문제'),
      (icon: Icons.percent_rounded, label: '전체 정답률', value: '${(StudyStats.totalAccuracy * 100).toStringAsFixed(0)}%'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.0,
      children: stats
          .map((s) => GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                      child: Icon(s.icon, size: 20, color: AppColors.primaryDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s.value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          Text(
                            s.label,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _WeeklyActivityCard extends StatelessWidget {
  const _WeeklyActivityCard();

  @override
  Widget build(BuildContext context) {
    final data = StudyStats.weeklyActivity;
    final maxMinutes = data.map((d) => d.minutes).reduce((a, b) => a > b ? a : b).clamp(1, 999);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('최근 7일 학습 활동', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 18),
          SizedBox(
            height: 116,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final isToday = d == data.last;
                final barHeight = d.minutes == 0 ? 4.0 : 8 + (d.minutes / maxMinutes) * 46;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          d.minutes == 0 ? '' : '${d.minutes}',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: barHeight,
                            decoration: BoxDecoration(
                              gradient: isToday
                                  ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.primary, Color(0xFF3E6FB0)])
                                  : null,
                              color: isToday ? null : AppColors.trackBg,
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          d.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                            color: isToday ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectProgressCard extends StatelessWidget {
  final ExamSubject subject;
  const _SubjectProgressCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final style = subjectStyleOf(subject.id);
    final progress = mockSubjectProgress[subject.id] ?? 0;

    return GlassCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SubjectChaptersScreen(subjectId: subject.id, subjectName: subject.name)),
      ),
      child: Row(
        children: [
          ProgressRing(progress: progress, color: style.color, size: 44, strokeWidth: 5),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: style.color.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation(style.color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
