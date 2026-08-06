/// 웹에서는 실제 게이트 로직(blog_gate_web.dart)을, 그 외(테스트 VM 등)에서는
/// 항상 통과시키는 대체 구현(blog_gate_stub.dart)을 쓴다.
library;

export 'blog_gate_stub.dart' if (dart.library.html) 'blog_gate_web.dart';
