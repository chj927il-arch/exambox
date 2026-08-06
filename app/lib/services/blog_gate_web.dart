import 'dart:html' as html;

const _kRefParam = 'ref';
const _kRefValue = 'blog';
const _kSessionKey = 'entered_via_blog';

/// 블로그를 거쳐 들어온 경우(`?ref=blog`)만 통과시키고, 그 상태를 sessionStorage에
/// 남긴다. sessionStorage는 새로고침해도 유지되지만 탭/창을 닫으면 사라지므로,
/// "새로고침은 괜찮지만 창을 닫고 다시 열면 블로그를 다시 거쳐야 한다"는 동작이 된다.
bool checkBlogGateAccess() {
  final uri = Uri.base;
  if (uri.queryParameters[_kRefParam] == _kRefValue) {
    html.window.sessionStorage[_kSessionKey] = '1';
    _cleanUrlParam(uri);
    return true;
  }
  return html.window.sessionStorage[_kSessionKey] == '1';
}

/// 주소창에 `?ref=blog`가 계속 보이지 않도록, 통과 확인 직후 히스토리를 교체해 지운다.
void _cleanUrlParam(Uri uri) {
  final params = Map<String, String>.from(uri.queryParameters)..remove(_kRefParam);
  final cleanUri = uri.replace(queryParameters: params.isEmpty ? null : params);
  html.window.history.replaceState(null, '', cleanUri.toString());
}

void goToBlog(String url) {
  html.window.location.href = url;
}
