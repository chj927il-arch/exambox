import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// 이메일/비밀번호 회원가입·로그인 — 기존 익명 로그인(좋아요·댓글용) 위에 붙는다.
/// 회원가입은 현재 세션의 익명 계정에 이메일 자격증명을 연결(link)해서 uid를 그대로 유지한다.
/// (연결에 실패하면 — 이미 다른 기기에서 가입된 계정이거나 하는 경우 — 새로 로그인만 시도한다.)
class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Firebase가 초기화되지 않은 환경(위젯 테스트 등)에서는 null로 조용히 대체한다.
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// 실제 회원(이메일 계정)으로 로그인된 상태인지 — 익명 세션은 게스트로 취급한다.
  bool get isLoggedIn => currentUser != null && !currentUser!.isAnonymous;

  void init() {
    try {
      _auth.authStateChanges().listen((_) => notifyListeners());
    } catch (_) {
      // Firebase가 초기화되지 않은 환경(예: 위젯 테스트)에서는 조용히 비활성 상태로 남긴다.
    }
  }

  Future<String?> signUp({required String email, required String password}) async {
    try {
      final current = _auth.currentUser;
      if (current != null && current.isAnonymous) {
        await current.linkWithCredential(
          EmailAuthProvider.credential(email: email, password: password),
        );
      } else {
        await _auth.createUserWithEmailAndPassword(email: email, password: password);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageFor(e);
    } catch (_) {
      return '회원가입 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.';
    }
  }

  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageFor(e);
    } catch (_) {
      return '로그인 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.';
    }
  }

  /// 로그아웃 후 좋아요/댓글이 계속 동작하도록 새 익명 세션을 만든다.
  Future<void> signOut() async {
    await _auth.signOut();
    await _auth.signInAnonymously();
  }

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
      case 'credential-already-in-use':
        return '이미 가입된 이메일이에요. 로그인해주세요.';
      case 'invalid-email':
        return '이메일 형식이 올바르지 않아요.';
      case 'weak-password':
        return '비밀번호는 6자 이상으로 입력해주세요.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return '이메일 또는 비밀번호가 올바르지 않아요.';
      default:
        return '오류가 발생했어요. (${e.code})';
    }
  }
}
