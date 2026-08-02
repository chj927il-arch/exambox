import 'package:flutter_test/flutter_test.dart';
import 'package:gamyeong_exam/data/mock_exam.dart';

void main() {
  for (final subjectId in ['economic_law', 'civil_law', 'business_admin']) {
    test('$subjectId 모의고사는 40문제를 중복 없이 구성한다', () {
      final questions = buildMockExam(subjectId, totalCount: 40, seed: 1);
      expect(questions.length, 40);
      expect(questions.every((q) => q.subjectId == subjectId), isTrue);
      expect(questions.map((q) => q.id).toSet().length, 40);
    });
  }
}
