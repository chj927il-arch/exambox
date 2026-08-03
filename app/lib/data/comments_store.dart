import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'comment_item.dart';

/// 카드별 댓글 — Firestore `comments/{cardId}/items` 서브컬렉션에 저장되어
/// 모든 사용자에게 실시간으로 공유된다. [LikesStore]와 동일하게 익명 로그인(uid)만으로
/// 작성자를 구분하고, 화면에는 이름을 표시하지 않는다(전부 "학습자"로 표시).
class CommentsStore extends ChangeNotifier {
  CommentsStore._();
  static final CommentsStore instance = CommentsStore._();

  final Map<String, List<CommentItem>> _comments = {};
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> _subscriptions = {};
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

  List<CommentItem> commentsFor(String cardId) {
    _ensureSubscribed(cardId);
    return _comments[cardId] ?? const [];
  }

  int countFor(String cardId) => commentsFor(cardId).length;

  void _ensureSubscribed(String cardId) {
    if (_subscriptions.containsKey(cardId)) return;
    try {
      final query = FirebaseFirestore.instance
          .collection('comments')
          .doc(cardId)
          .collection('items')
          .orderBy('createdAt', descending: true);
      _subscriptions[cardId] = query.snapshots().listen((snapshot) {
        _comments[cardId] = snapshot.docs.map(CommentItem.fromDoc).toList();
        notifyListeners();
      });
    } catch (_) {
      // Firebase가 초기화되지 않은 환경(예: 위젯 테스트)에서는 조용히 무시한다.
    }
  }

  Future<void> add(String cardId, String text) async {
    final uid = _uid;
    final trimmed = text.trim();
    if (uid == null || trimmed.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('comments').doc(cardId).collection('items').add({
        'text': trimmed,
        'authorUid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
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
