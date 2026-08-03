import 'package:flutter/material.dart';
import '../data/likes_store.dart';
import 'comment_badge.dart';

/// 그리드 카드 우상단에 올려두는 좋아요(하트) 배지 — 누르면 토글되고 개수가 즉시 반영된다.
/// [likeId]는 카드마다 고유해야 한다(예: 과목ID+카테고리 조합).
class LikeBadge extends StatelessWidget {
  final String likeId;
  const LikeBadge({super.key, required this.likeId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LikesStore.instance,
      builder: (context, _) {
        final liked = LikesStore.instance.isLikedByMe(likeId);
        final count = LikesStore.instance.countFor(likeId);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => LikesStore.instance.toggle(likeId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: liked ? const Color(0xFFFF5C7A) : Colors.white,
                    size: 15,
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 3),
                    Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
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

/// 좋아요 + 댓글 배지를 나란히 묶어 카드 위에 올리는 편의 위젯 — 카드마다 이거 하나만
/// 붙이면 됨(같은 [cardId]를 좋아요·댓글 식별자로 함께 사용).
class EngagementBadges extends StatelessWidget {
  final String cardId;
  const EngagementBadges({super.key, required this.cardId});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LikeBadge(likeId: cardId),
        const SizedBox(width: 6),
        CommentBadge(cardId: cardId),
      ],
    );
  }
}
