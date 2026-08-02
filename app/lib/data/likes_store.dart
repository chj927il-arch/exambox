import 'package:flutter/foundation.dart';

/// 그리드 카드별 "좋아요" 상태를 기억하는 저장소.
/// (UserProgress와 동일하게 메모리에만 저장됨 — 새로고침하면 초기화된다.)
class LikesStore extends ChangeNotifier {
  LikesStore._();
  static final LikesStore instance = LikesStore._();

  final Map<String, int> _counts = {};
  final Set<String> _likedByMe = {};

  int countFor(String id) => _counts[id] ?? 0;
  bool isLikedByMe(String id) => _likedByMe.contains(id);

  void toggle(String id) {
    if (_likedByMe.remove(id)) {
      _counts[id] = (_counts[id] ?? 1) - 1;
    } else {
      _likedByMe.add(id);
      _counts[id] = (_counts[id] ?? 0) + 1;
    }
    notifyListeners();
  }
}
