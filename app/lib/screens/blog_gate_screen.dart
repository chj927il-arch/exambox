import 'package:flutter/material.dart';
import '../services/blog_gate.dart';
import '../theme/app_theme.dart';

/// 블로그를 거치지 않고 들어온 경우(직접 URL·즐겨찾기 등) 보여주는 안내 화면.
/// TODO: 문제은행 소개 포스팅을 올리면, 그 포스팅 주소로 바꿔주세요(지금은 블로그 메인 주소).
const _kBlogUrl = 'https://blog.naver.com/franchisestory';

class BlogGateScreen extends StatelessWidget {
  const BlogGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/blog_banner_wise_examlife.png',
                    width: 320,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '문제은행 사이트로 이동하기 위해서는\n\'슬기로운 수험생활\' 블로그를 통해 접속해주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.4),
                ),
                const SizedBox(height: 10),
                const Text(
                  '블로그 포스팅의 "바로가기" 링크로 들어오시면 돼요.\n한 번 들어오면 새로고침해도 계속 이용할 수 있어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => goToBlog(_kBlogUrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    elevation: 4,
                  ),
                  child: const Text(
                    '슬기로운 수험생활 블로그로 이동하기',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
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
