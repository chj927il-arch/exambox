import 'package:flutter/foundation.dart';
import 'board_data.dart';

/// 사용자가 직접 작성한 수강후기를 기억하는 저장소.
/// (UserProgress와 동일하게 현재는 메모리에만 저장됨 — 앱을 새로고침하면 초기화됩니다.
/// 추후 서버 연동 시 여기에 실제 저장/조회 로직을 붙이면 된다.)
class UserReviews extends ChangeNotifier {
  UserReviews._();
  static final UserReviews instance = UserReviews._();

  final List<ReviewItem> _submitted = [];

  List<ReviewItem> get submitted => List.unmodifiable(_submitted);

  void add(ReviewItem review) {
    _submitted.insert(0, review);
    notifyListeners();
  }
}
