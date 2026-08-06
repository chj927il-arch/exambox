/// 웹이 아닌 환경(예: `flutter test`가 쓰는 VM 테스트 러너)용 대체 구현 — 항상 통과시킨다.
/// 실제 게이트 로직은 blog_gate_web.dart(dart:html 사용)에만 있다.
bool checkBlogGateAccess() => true;

void goToBlog(String url) {}
