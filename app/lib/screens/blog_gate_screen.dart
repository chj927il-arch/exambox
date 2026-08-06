import 'package:flutter/material.dart';
import '../services/blog_gate.dart';
import '../theme/app_theme.dart';

/// 블로그를 거치지 않고 들어온 경우(직접 URL·즐겨찾기 등) 보여주는 안내 화면.
/// TODO: 실제 블로그 주소로 교체하세요.
const _kBlogUrl = 'https://blog.naver.com/여기에_블로그_주소를_넣어주세요';

class BlogGateScreen extends StatelessWidget {
  const BlogGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  '블로그를 통해서만 입장할 수 있어요',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                const Text(
                  '블로그 포스팅의 "바로가기" 버튼으로 다시 들어와주세요.\n한 번 들어오면 새로고침해도 계속 이용할 수 있어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => goToBlog(_kBlogUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('블로그로 이동', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
