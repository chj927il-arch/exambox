# CLAUDE.md

이 파일은 Claude Code가 이 저장소에서 작업할 때 자동으로 읽는 프로젝트 지침입니다.
새 PC에서 이 저장소를 클론해 Claude Code로 열면 이 파일이 자동으로 컨텍스트에 포함됩니다.

## 프로젝트 한 줄 요약
가맹거래사 1차 시험(경제법·민법·경영학) 준비생을 위한 AI 기반 문제은행 모바일 앱 **"스터디박스"**.
큐넷 기출문제를 Gemini로 분석(출제의도·핵심·최근 이슈)해 유사문제를 무한 생성하고,
사용자가 정답/오답을 반복해서 풀며 자연스럽게 개념을 익히는 **듀오링고식 학습 구조**.
오답뿐 아니라 정답 문제도 유사문제를 계속 반복 노출. 해설은 길게 쓰지 않고 핵심만 요약,
사용자가 원하는 해설만 골라 **단권화 노트**를 만들 수 있게 함.
추후 앱스토어/플레이스토어 정식 출시, **유료 판매** 예정.

## 저장소 · 배포
- **GitHub (비공개)**: https://github.com/chj927il-arch/exambox (2026-08-03 `gamyeong-exam`에서 이름 변경)
- **배포(GitHub Pages, 웹)**: https://chj927il-arch.github.io/exambox/ — `master` 브랜치의 `app/**` 변경 시 `.github/workflows/deploy.yml`이 자동으로 `flutter build web`(`--base-href /exambox/`) 후 `gh-pages` 브랜치에 배포 (보통 1~2분).
- 로컬 경로: 회사 PC `C:\gamyeong-exam`(폴더명은 그대로 — 저장소 이름만 바뀜, Flutter 프로젝트명도 `gamyeong_exam` 그대로 유지) — 집 PC는 각자 클론 위치, `git pull`로 항상 최신화할 것

## 기술 스택
- **모바일 앱**: Flutter (iOS/Android/웹 단일 코드베이스, org `com.gamyeongexam`, 프로젝트명 `gamyeong_exam`)
- **백엔드/인프라**: Firebase 예정 (Auth·Firestore·Functions·인앱결제) — **아직 연동 안 함**
- **AI 문제 생성/분석**: Google Gemini API 예정 — **아직 연동 안 함** (competitor 프로젝트에서 사용 경험 있음)
- Android SDK/Android Studio가 이 PC엔 없어 Android 네이티브 빌드는 아직 불가. **웹으로는 실행 가능**(`flutter run -d chrome` 또는 `flutter run -d web-server --web-port=포트`).
  iOS는 Windows에서 빌드 불가(Mac 또는 Codemagic 등 클라우드 빌드 필요).

## 디자인
- **라이트 테마 확정**: 화이트 배경 + 네이비 키컬러(`AppColors.primary #1B3358`) + 골드/퍼플 포인트, Pretendard(에셋 폰트)/IBM Plex Sans KR.
  (초기엔 다크+글래스모피즘으로 시도했다가, 이후 라이트+네이비 브랜드 톤으로 최종 확정됨 — `app_theme.dart` 참고)
- 재사용 위젯: `widgets/glass_card.dart`(GlassCard), `widgets/app_background.dart`(배경), `widgets/empty_state.dart`(빈 상태)
- 웹에서도 폰 앱처럼 보이도록 `main.dart`의 `MaterialApp.builder`가 최대 폭 430px로 제한

## 코드 구조
```
app/lib/
  main.dart                    # 앱 진입점, 폰트 프리로드, 폭 제한 builder
  screens/
    splash_screen.dart         # 시작 시 1초 스플래시 → RootScreen (로그인 없음)
    root_screen.dart           # 최상위: 상단탭(홈/시험소개/시험과목/마이페이지) + 하단 "학습하기" 볼록버튼
    home_screen.dart           # 홈: 런칭배너·롤링배너·데일리OX·수강후기·FAQ·공지
    study_screen.dart          # "학습하기" 탭 진입점 — 과목(경제법/민법/경영학) 목록
    subject_chapters_screen.dart # 과목 선택 시 챕터(유형)별 출제비중 목록 → 챕터 탭하면 QuizScreen
    quiz_screen.dart           # 문제풀이 화면 (아래 "문제풀이 흐름" 참고)
    exam_subjects_screen.dart / subject_info_screen.dart / exam_intro_screen.dart  # 시험 정보
    mypage_screen.dart         # 마이페이지: 학습리포트(오늘목표·통계·취약챕터) + 오답노트 진입
    wrong_note_screen.dart     # 오답노트 (UserProgress 기반 실데이터)
    daily_ox_list_screen.dart / daily_ox_detail_screen.dart  # 데일리 OX 퀴즈
    faq_screen.dart / notice_screen.dart / review_screen.dart  # 게시판형 화면들
  data/
    sample_questions.dart      # 실제 문제 데이터 (경제법 위주로 구성됨, 민법/경영학은 챕터만)
    user_progress.dart         # ⭐ 실제 학습 기록 저장소 (UserProgress, ChangeNotifier 싱글턴)
    study_stats.dart           # 마이페이지가 읽는 통계 — 학습시간/정답수/취약챕터는 UserProgress 프록시,
                                #   연속학습일·주간활동차트는 아직 목업(날짜별 이력 저장 미구현)
    topic_stats.dart           # 과목별 챕터·출제비중 (경제법은 실제 기출분석, 민법/경영학은 챕터명만)
    board_data.dart / ox_quiz_data.dart  # 게시판/OX퀴즈 데이터
  models/                      # Question, ExamSubject 등 데이터 모델
  theme/                       # app_theme.dart(라이트 테마), subject_style.dart(과목별 아이콘/색)
  widgets/                     # 배너·마퀴·글래스카드 등 재사용 위젯
```
실행 확인: `cd app && flutter run -d web-server --web-port=아무포트` 후 브라우저에서 `http://localhost:포트`
테스트: `cd app && flutter test`

## 문제풀이 흐름 (quiz_screen.dart, 2026-07-21 추가)
- 상단에 경과시간 타이머 표시(mm:ss), 문제 풀이 중 계속 누적됨.
- 마지막 문제까지 풀면 **완료 화면**(걸린 시간·정답수) + **복습하기/끝내기** 버튼 노출.
  - 복습하기: `_questions.shuffle()`로 순서를 섞어 처음부터 재도전 (같은 문제 그대로 다시 보이지 않게).
  - 끝내기: `Navigator.popUntil(isFirst)`로 해당 탭(학습하기)의 첫 화면인 `StudyScreen`(과목 메뉴)까지 복귀.
- 문제를 답할 때마다 `UserProgress.instance.recordAnswer(...)` 호출 → 총/오늘 정답수, 챕터별 정답률 누적.
  퇴장(끝내기 또는 뒤로가기) 시 `UserProgress.instance.addStudySeconds(...)`로 학습시간 확정 반영(dispose에서도 안전하게 커밋).
- 마이페이지(`mypage_screen.dart`)는 `UserProgress`를 `ListenableBuilder`로 구독해서 실시간 반영.
  취약 챕터는 시도 3회 미만인 챕터는 신뢰도가 낮아 제외(데이터 부족 시 안내 문구).
- ⚠️ `UserProgress`는 메모리에만 저장 — **앱 재시작하면 초기화됨**. 로컬 저장소(예: shared_preferences) 연동은 아직 안 함.

## 남은 작업
- [ ] Firebase 프로젝트 생성/연동 (Auth·Firestore·인앱결제)
- [ ] Gemini API 키 발급/연동, 실제 유사문제 생성 로직
- [ ] 큐넷 기출문제 확보 방식 결정, 민법·경영학 기출 분석
- [ ] 학습 기록 로컬/서버 영구 저장 (현재는 메모리 휘발성)
- [ ] 연속학습일(streak)·주간활동차트 실데이터화 (날짜별 이력 저장 필요)
- [ ] 단권화 노트 화면 실제 데이터 연동
- [ ] 회원가입/로그인, 인앱결제

## 여러 PC에서 이어작업하기
1. `git clone https://github.com/chj927il-arch/exambox.git` (이미 클론했다면 `git pull`)
2. 해당 PC에 Flutter SDK 설치 필요 (미설치 시 Claude에게 설치 요청 가능)
3. **iOS 빌드/테스트는 Windows에서 불가능** (Xcode는 Mac 전용). Android는 SDK 설치 후 가능, 웹은 바로 가능.
4. Firebase 프로젝트는 `studybox-gamyeong-c4176` — `app/lib/firebase_options.dart`(웹 전용 공개 설정값이라 git에 커밋되어 있음)가 이미 저장소에 포함돼 있어 별도 설정 없이 바로 빌드됨. `android/key.properties` 등 진짜 비밀값(아직 없음)만 PC마다 따로 옮기면 됨.

## 절대 지켜야 할 규칙
1. **AI 모델은 Google Gemini만 사용.**
2. **API 키 등 비밀값은 코드/로그/커밋/문서에 절대 노출 금지.** `.env` 등으로만 관리.
3. **한글 파일 작성 시 반드시 UTF-8.**
4. **사용자는 비개발자 + Windows + 한국어.** 명령어는 복붙 가능한 단일 라인, 설명은 쉽게.
