import 'package:cloud_firestore/cloud_firestore.dart';

/// 카드(강의/과목 등)에 달린 댓글 하나. 로그인 UI가 아직 없어 작성자 이름은 없고,
/// 익명으로만 표시한다.
class CommentItem {
  final String id;
  final String text;
  final DateTime? createdAt;

  const CommentItem({required this.id, required this.text, required this.createdAt});

  factory CommentItem.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final ts = data['createdAt'];
    return CommentItem(
      id: doc.id,
      text: (data['text'] as String?) ?? '',
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
