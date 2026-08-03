import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// 그리드 카드별 "좋아요" 상태 — Firestore(`likes` 컬렉션)에 저장되어 모든 사용자에게
/// 실시간으로 공유된다. 문서 하나당 `likedBy`(좋아요 누른 uid 배열) 필드만 가지고,
/// 좋아요 수는 그 배열 길이로 계산한다. 로그인 UI는 아직 없어 [init]에서 익명 로그인으로
/// 기기별 uid만 확보한다(같은 기기·브라우저에서는 새로고침해도 좋아요 상태 유지).
class LikesStore extends ChangeNotifier {
  LikesStore._();
  static final LikesStore instance = LikesStore._();

  final Map<String, int> _counts = {};
  final Set<String> _likedByMe = {};
  final Map<String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>> _subscriptions = {};
  String? _uid;

  Future<void> init() async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser ?? (await auth.signInAnonymously()).user;
      _uid = user?.uid;
    } catch (_) {
      // Firebase가 초기화되지 않은 환경(예: 위젯 테스트)에서는 조용히 비활성 상태로 남긴다.
    }
  }

  int countFor(String id) {
    _ensureSubscribed(id);
    return _counts[id] ?? 0;
  }

  bool isLikedByMe(String id) {
    _ensureSubscribed(id);
    return _likedByMe.contains(id);
  }

  void _ensureSubscribed(String id) {
    if (_subscriptions.containsKey(id)) return;
    try {
      final doc = FirebaseFirestore.instance.collection('likes').doc(id);
      _subscriptions[id] = doc.snapshots().listen((snapshot) {
        final likedBy = (snapshot.data()?['likedBy'] as List?)?.cast<String>() ?? const <String>[];
        _counts[id] = likedBy.length;
        if (_uid != null && likedBy.contains(_uid)) {
          _likedByMe.add(id);
        } else {
          _likedByMe.remove(id);
        }
        notifyListeners();
      });
    } catch (_) {
      // Firebase가 초기화되지 않은 환경(예: 위젯 테스트)에서는 조용히 무시한다.
    }
  }

  Future<void> toggle(String id) async {
    final uid = _uid;
    if (uid == null) return;
    final wasLiked = _likedByMe.contains(id);
    // 낙관적 업데이트 — 서버 응답을 기다리지 않고 즉시 반영해 탭 반응이 느려 보이지 않게 한다.
    if (wasLiked) {
      _likedByMe.remove(id);
      _counts[id] = (_counts[id] ?? 1) - 1;
    } else {
      _likedByMe.add(id);
      _counts[id] = (_counts[id] ?? 0) + 1;
    }
    notifyListeners();
    try {
      final doc = FirebaseFirestore.instance.collection('likes').doc(id);
      await doc.set({
        'likedBy': wasLiked ? FieldValue.arrayRemove([uid]) : FieldValue.arrayUnion([uid]),
      }, SetOptions(merge: true));
    } catch (_) {
      // Firebase가 초기화되지 않은 환경(예: 위젯 테스트)에서는 조용히 무시한다.
    }
  }

  @override
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    super.dispose();
  }
}
