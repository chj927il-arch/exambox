import 'package:flutter/material.dart';
import '../data/comments_store.dart';

/// 카드 위에 올려두는 댓글 배지 — 말풍선 아이콘 + 댓글 수. 누르면 댓글 목록/작성
/// 바텀시트가 뜬다. [cardId]는 좋아요와 동일한 카드 식별자를 그대로 쓰면 된다.
class CommentBadge extends StatelessWidget {
  final String cardId;
  const CommentBadge({super.key, required this.cardId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CommentsStore.instance,
      builder: (context, _) {
        final count = CommentsStore.instance.countFor(cardId);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => _openCommentSheet(context, cardId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mode_comment_outlined, color: Colors.white, size: 14),
                  if (count > 0) ...[
                    const SizedBox(width: 3),
                    Text(
                      '$count',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void _openCommentSheet(BuildContext context, String cardId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF141821),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => _CommentSheet(cardId: cardId),
  );
}

class _CommentSheet extends StatefulWidget {
  final String cardId;
  const _CommentSheet({required this.cardId});

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    CommentsStore.instance.add(widget.cardId, text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(999))),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text('댓글', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: CommentsStore.instance,
                builder: (context, _) {
                  final comments = CommentsStore.instance.commentsFor(widget.cardId);
                  if (comments.isEmpty) {
                    return const Center(
                      child: Text('아직 댓글이 없어요. 첫 댓글을 남겨보세요!', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: comments.length,
                    separatorBuilder: (_, _) => const Divider(color: Colors.white12, height: 20),
                    itemBuilder: (context, index) {
                      final c = comments[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('학습자', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(c.text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      maxLength: 300,
                      decoration: const InputDecoration(
                        hintText: '댓글을 남겨보세요',
                        hintStyle: TextStyle(color: Colors.white38),
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _submit,
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
