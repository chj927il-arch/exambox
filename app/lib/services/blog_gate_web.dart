import 'dart:html' as html;

/// 이 도메인에서 실제로 링크를 클릭해서 넘어온 경우만 통과시킨다.
/// URL에 어떤 파라미터를 붙였는지는 더 이상 보지 않는다 — 그 주소를 알고 있거나
/// 북마크해둔 것만으로는 더 이상 통과되지 않고, 매번 이 블로그의 글을 거쳐야 한다.
const _kBlogHost = 'blog.naver.com';
const _kSessionKey = 'entered_via_blog';

/// `document.referrer`(브라우저가 실제 이전 페이지 주소를 담아 보내주는 값)가
/// 블로그 도메인이면 통과시키고 세션에 남긴다. sessionStorage는 새로고침해도
/// 유지되지만 탭/창을 닫으면 사라지므로, "새로고침은 괜찮지만 창을 닫고 다시 열면
/// 블로그를 다시 거쳐야 한다"는 동작이 된다.
bool checkBlogGateAccess() {
  if (html.window.sessionStorage[_kSessionKey] == '1') return true;

  final referrer = html.document.referrer;
  if (referrer.contains(_kBlogHost)) {
    html.window.sessionStorage[_kSessionKey] = '1';
    return true;
  }
  return false;
}

void goToBlog(String url) {
  html.window.location.href = url;
}
