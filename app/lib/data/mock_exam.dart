import 'dart:math';

import '../models/question.dart';
import 'sample_questions.dart';
import 'topic_stats.dart';

/// 실전모의고사 문제 구성 — 실제 기출 출제비중(topic_stats.dart)에 맞춰 챕터별로
/// 문항 수를 배분한 뒤, 각 챕터 안에서 무작위로 뽑아 최종 순서를 다시 섞는다.
/// 실제 시험처럼 챕터 순서대로 몰아서 나오지 않고 뒤섞여 출제되도록 하기 위함이다.
List<Question> buildMockExam(String subjectId, {int totalCount = 40, int? seed}) {
  final random = seed == null ? Random() : Random(seed);
  final topics = chapterStatsFor(subjectId);
  final pool = sampleQuestions.where((q) => q.subjectId == subjectId).toList();
  if (topics.isEmpty || pool.isEmpty) {
    final shuffled = [...pool]..shuffle(random);
    return shuffled.take(totalCount).toList();
  }

  // 1) 챕터별 목표 문항 수를 실제 출제비중에 맞춰 배분(가장 큰 나머지 방식으로 반올림 오차를 보정).
  final rawCounts = topics.map((t) => t.ratio * totalCount).toList();
  final baseCounts = rawCounts.map((c) => c.floor()).toList();
  var remaining = totalCount - baseCounts.fold<int>(0, (a, b) => a + b);
  final remainders = List.generate(topics.length, (i) => rawCounts[i] - baseCounts[i]);
  final order = List.generate(topics.length, (i) => i)..sort((a, b) => remainders[b].compareTo(remainders[a]));
  for (var i = 0; i < remaining && i < order.length; i++) {
    baseCounts[order[i]]++;
  }
  remaining = 0;

  // 2) 챕터별로 실제 보유 문제 중에서 목표 수만큼 무작위로 뽑는다. 모자라면 부족분을
  //    기록해뒀다가 나중에 다른 챕터(문제가 넉넉한 쪽)에서 채운다.
  final selected = <Question>[];
  final usedIds = <String>{};
  var shortfall = 0;
  for (var i = 0; i < topics.length; i++) {
    final want = baseCounts[i];
    if (want <= 0) continue;
    final candidates = pool.where((q) => q.category == topics[i].topic).toList()..shuffle(random);
    final take = min(want, candidates.length);
    for (final q in candidates.take(take)) {
      if (usedIds.add(q.id)) selected.add(q);
    }
    shortfall += want - take;
  }

  if (shortfall > 0) {
    final leftover = pool.where((q) => !usedIds.contains(q.id)).toList()..shuffle(random);
    for (final q in leftover) {
      if (selected.length >= totalCount) break;
      if (usedIds.add(q.id)) selected.add(q);
    }
  }

  selected.shuffle(random);
  return selected.take(totalCount).toList();
}
