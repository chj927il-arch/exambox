import 'package:flutter/material.dart';

import '../data/comments_store.dart';
import '../data/likes_store.dart';
import '../data/user_progress.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

/// 이메일/비밀번호 로그인·회원가입 화면 — 로그인하면 그 순간부터 학습 기록이
/// Firestore에 저장되어 마이페이지 리포트에 실제 값으로 반영된다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = '이메일과 비밀번호를 입력해주세요.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = AuthService.instance;
    final error = _isSignUp
        ? await auth.signUp(email: email, password: password)
        : await auth.signIn(email: email, password: password);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }
    final uid = auth.currentUser?.uid;
    LikesStore.instance.setUid(uid);
    CommentsStore.instance.setUid(uid);
    await UserProgress.instance.attachUser(uid);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.trackBg,
      appBar: AppBar(
        backgroundColor: AppColors.trackBg,
        elevation: 0,
        title: Text(_isSignUp ? '회원가입' : '로그인'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isSignUp ? '가입하고 학습 기록을 저장해보세요' : '다시 만나서 반가워요',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              '로그인하면 문제풀이 기록이 저장되어 기기를 바꿔도 학습리포트가 이어져요.',
              style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500, height: 1.5),
            ),
            const SizedBox(height: 20),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: '이메일', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '비밀번호(6자 이상)', border: OutlineInputBorder()),
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4))
                          : Text(_isSignUp ? '가입하고 시작하기' : '로그인'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: TextButton(
                onPressed: _loading
                    ? null
                    : () => setState(() {
                          _isSignUp = !_isSignUp;
                          _error = null;
                        }),
                child: Text(_isSignUp ? '이미 계정이 있어요 · 로그인' : '계정이 없어요 · 회원가입'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
