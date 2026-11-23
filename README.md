# ✈️ PlanB — AI Travel Planner on My Budget

> 내 예산과 목표에 맞춰 AI가 여행 플랜을 추천하고, 출발 전까지의 준비 및 저축까지 함께 관리해 주는 여행 플래너 앱 **PlanB**

<!-- 프로젝트 대표 이미지 자리 -->

<br>

## 📌 프로젝트 설명

**PlanB**는 사용자의 예산에 최적화된 '실현 가능한' 여행을 설계하는
AI 기반 스케줄링 플랫폼입니다.
- 사용자는 **지갑 기준(예산 먼저)** 또는 **목표 기준(여행지 먼저)** 중 하나를 골라 여행 조건을 입력하고
- AI가 조건에 맞는 여행 플랜을 추천합니다.
- 플랜을 확정하면 출발일까지 **월별 준비 가이드**와 **나의 여행 코스**를 따라가며 여행을 준비할 수 있습니다.

<br>

## ✨ 주요 플로우 및 기능

| 기능 | 설명 |
| --- | --- |
| 1. 로그인 | 카카오 / 구글 소셜 로그인 (토큰 기반 세션 유지 및 자동 갱신) |
| 2. 맞춤 여행 체크 | 여행 계획 기준(지갑 기준 / 목표 기준) 선택 → 기본 정보, 예산, 세부 여행 취향을 단계별로 입력 |
| 3. 여행 고르기 | 사용자의 입력 조건을 분석해 AI가 여행 플랜을 추천: 티켓/영수증 형태의 카드로 제공된 여행 플랜을 비교하여 선택 → 나의 플랜 생성 완료 |
| 4. 홈 | 내 여행 플랜 목록을 상태(예정 / 진행 / 완료)별로 확인 가능 |
| 5. 나의 여행 플래너 | 확정한 플랜의 기본 정보, 주요 코스, 항목별 예상 비용을 한눈에 확인 |
| 6. 월별 여행 준비 가이드 | 여행 출발일까지 월별 / 전체 타임라인으로 여행 준비 항목을 확인하고 월별로 준비 |
| 7. 여행 코스 | 웹에서 찾은 링크를 붙여 넣으면 코스 정보를 추출해 나의 여행 코스에 추가 |
| 8. 마이페이지 | 프로필(이름) 수정, 앱 설정, 로그아웃 및 회원 탈퇴 |

<br>

## 🛠 기술 스택

| 구분 | 사용 기술 |
| --- | --- |
| Framework | Flutter (Dart SDK ^3.10.0) |
| 상태 관리 | flutter_riverpod |
| 라우팅 | go_router (StatefulShellRoute) |
| 네트워크 | dio (+ 인증 인터셉터) |
| 모델 / 직렬화 | freezed, json_serializable, build_runner |
| 인증 | kakao_flutter_sdk_user, google_sign_in, flutter_secure_storage |
| 환경 변수 | flutter_dotenv |
| 기타 | flutter_svg, url_launcher, flutter_native_splash, flutter_launcher_icons |
| 협업 | GitHub Issues / Projects, CodeRabbit (AI 코드 리뷰) |

<br>

## 🚀 설치 및 실행

### 1. 요구 사항
- Flutter SDK (Dart ^3.10.0 포함 버전)
- Xcode (iOS 빌드), CocoaPods

### 2. 프로젝트 클론 및 패키지 설치
```bash
git clone https://github.com/PlanBproject-dev/frontend.git
cd frontend
flutter pub get
```

### 3. 환경 변수 설정
프로젝트 루트에 `.env` 파일을 만들고 아래 값을 채워주세요. (실제 값은 팀 노션으로 공유)
```env
BASE_URL=
KAKAO_NATIVE_KEY=
GOOGLE_IOS_CLIENT_ID=
GOOGLE_SERVER_CLIENT_ID=
```

### 4. 코드 생성 (freezed / json_serializable)
모델을 수정했다면 생성 파일을 다시 만들어 주세요.
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. 실행
```bash
flutter run
```

<br>

## 🌳 브랜치 전략

```
main        배포용 브랜치
 └─ develop     개발 통합 브랜치 (모든 PR의 base)
     └─ feature/#이슈번호-작업내용   기능 단위 작업 브랜치
```

- 작업 시작 전 **이슈를 먼저 생성**하고, 이슈 번호로 브랜치를 생성합니다.
  - 예) `feature/#97-get-timeline-guide-api`
- 작업이 끝나면 `develop`을 base로 PR을 올리고, 리뷰 후 머지합니다.
- `develop`이 안정화되면 `main`에 반영합니다.

### 커밋 컨벤션
`#이슈번호 [태그] 작업 내용`

| 태그 | 의미 |
| --- | --- |
| `[FEAT]` | 새 기능 구현 |
| `[FIX]` | 버그 수정 |
| `[MOD]` | 기존 코드 수정 |
| `[UI]` | UI 구현 작업 |
| `[ADD]` | 파일, 코드, 에셋 등 추가 |
| `[REFACTOR]` | 리팩토링 |
| `[CHORE]` | 기타 잡다한 수정 (불필요한 코드 삭제 등) |
| `[SETTING]` | 프로젝트 및 환경 세팅 |

### PR 규칙
- base 브랜치는 `develop`
- PR 제목은 형식에 맞게, 라벨 등록
- 관련 이슈(`Closed #번호`), 주요 업데이트 항목, 스크린샷/실행 영상 첨부하여 작성할 것.

<br>

## 📁 폴더 구조

### 구조 관리 요약
- 기능(feature) 단위로 폴더를 나눕니다.
- 각 기능 안에서 `data` / `presentation` 레이어를 분리하여 관리합니다.

<br>

```
lib/
├── main.dart                 # 앱 진입점
├── core/                     # 앱 전역 인프라
│   ├── auth/                 # 로그인 상태(authProvider), 세션 관리
│   ├── config/               # 라우팅 (router, app_routes, shell, not_found)
│   ├── network/              # dio 설정, 인증 인터셉터, 공통 요청 처리
│   ├── storage/              # 토큰 / 프로필 로컬 저장 (secure storage)
│   ├── theme/                # Colors / Text Styles / Effects / Theme
│   └── env.dart              # 필수 환경변수
│
├── features/                 # 기능 단위 모듈
│   ├── login/                # 소셜 로그인
│   ├── home/                 # 홈 (여행 플랜 목록)
│   ├── trip_check/           # 맞춤 여행 체크 (여행 플랜 생성 조건 입력)
│   ├── trip_select/          # AI 추천 여행 고르기
│   ├── planner/              # 나의 여행 플래너
│   ├── monthly_guide/        # 월별 여행 준비 가이드
│   ├── course/               # 나의 여행 코스
│   └── my_page/              # 마이페이지 (설정)
│
└── shared/                   # 여러 기능에서 함께 쓰는 코드 관리.
    ├── models/               # 공용 모델 (User, Destination 등)
    ├── providers/            # 공용 상태 (전역 로딩, 선택된 플랜 id)
    └── widgets/              # 공용 위젯 (버튼, 내비게이션, 모달, 토스트 등)
```

각 feature 내부 구조:
```
features/<feature>/
├── data/
│   ├── models/               # 앱에서 쓰는 도메인 모델
│   │   └── dto/              # 서버 요청/응답 DTO
│   └── repositories/         # API 호출 + DTO <-> 모델 변환
└── presentation/
    ├── pages/                # 화면
    ├── providers/            # Riverpod 상태 (Notifier)
    └── widgets/              # 해당 기능 전용 위젯
```

<br>

## 🚏 라우팅 전략

`go_router`를 사용하며, `routerProvider` 하나에서 `GoRouter`를 생성합니다.

자세한 설계 배경은 👉 [라우팅 전략 문서 (Notion)](https://app.notion.com/p/4144e2264bfc80d2b3e4fd7c4605c809) 참고.

### 1. 화면을 3종류로 구분
| 구분 | 화면&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | 방식 |
| --- | --- | --- |
| **글로벌 Shell** (하단 글로벌 탭) | - 홈<br>- 새 플랜 생성<br>- 마이페이지 | `StatefulShellRoute.indexedStack` |
| **로컬 Shell** (개별 플랜 내부 탭) | - 나의 여행 플래너<br>- 월별 여행 준비 가이드<br>- 나의 여행 코스 | 홈 하위의 `StatefulShellRoute.indexedStack`, 루트 내비게이터에 올려 글로벌 탭바를 덮음 |
| **탭바 없는 화면** | - 로그인<br>- 맞춤 여행 체크<br>- 여행 고르기 | 루트 내비게이터의 일반 `GoRoute` |

- `indexedStack`을 사용하여, **탭을 오가도 각 탭의 화면 스택과 스크롤 위치가 유지**됩니다.

### 2. 경로 상수 관리 (`app_routes.dart`)
- `AppRoutes`: 화면 이동(`context.go` / `push`)에 쓰는 **전체 경로**
- `AppPaths`: `router.dart`에서 하위 라우트를 정의할 때만 쓰는 **하위 경로 상수**
- `AppRouteExtras`: 라우트 이동 시 `extra`로 넘기는 값

```
/login
/home
  └─ /home/plan/planner, monthly-guide, course(/add/extraction)
/my-page
/trip-check
  ├─ /type
  ├─ /budget-first/basic-info, budget, details
  ├─ /goal-first/basic-info, details, food-budget
  └─ /analysis
/trip-select
  └─ /completed
```

### 3. redirect 규칙
- 로그인 상태(`authProvider`)가 바뀌면 `refreshListenable`로 redirect를 다시 계산
- 비로그인 → `/login`
- 로그인 화면에서 로그인 완료 → 신규 회원은 `/trip-check`(온보딩), 기존 회원은 `/home`
- 선택된 플랜 없이 `/home/plan/...` 진입 → `/home`
- 정의되지 않은 경로 → `NotFoundPage`

### 4. 이동 방식
- 맞춤 여행 체크처럼 **단계가 이어지는 플로우는 `push`** 로 쌓아 뒤로가기 시 이전 단계로 돌아갈 수 있게 합니다. (`go`를 쓰면 중간 단계가 스택에서 빠짐)

<br>

## 🗃 데이터 관리 전략 — 불변 모델 하나로 입력 관리

맞춤 여행 체크는 여러 화면에 걸쳐 입력을 받지만, **입력값은 `TripCheckDraft`라는 불변(freezed) 모델 하나에 모아** 관리합니다.

```dart
@freezed
class TripCheckDraft with _$TripCheckDraft {
  const factory TripCheckDraft({
    TripSelectionType? tripType,   // 지갑 기준 / 목표 기준
    int? planId,                   // 서버에 저장된 플랜 id
    Destination? destination,
    DateTimeRange? travelPeriod,
    int? peopleCount,
    CompanionType? companionType,
    BudgetRange? maxBudget,        // 지갑 기준 플로우
    MealBudget? mealBudget,        // 목표 기준 플로우
    @Default({}) Set<TravelStyle> travelStyles,
    ...
  }) = _TripCheckDraft;
}
```

- **단일 상태 소스**: 플로우 전체가 `tripCheckDraftProvider`(Riverpod `Notifier`) 하나를 공유합니다. 화면마다 상태를 따로 두지 않아 단계 간 값 전달이 필요 없습니다.
- **불변 + `copyWith`**: 화면은 값을 직접 바꾸지 않고 Notifier의 메서드를 호출하고, Notifier는 `state = state.copyWith(...)`로 새 객체를 만듭니다. 변경 지점이 한곳에 모여 추적이 쉽습니다.
- **플로우 단위 초기화**: 인트로에서 시작할 때 `reset()`, 여행 기준(지갑/목표)이 바뀌면 이후 입력을 초기화, 로그아웃·계정 변경 시에도 초기화합니다.
- **복원**: 플래너에서 "여행 플랜 다시 선택하기" 시 저장된 조건으로 `restore()` 합니다.
- **안전한 임시 저장**: 저장 요청은 대기열로 순서대로 처리하고, 플로우 번호로 이전 플로우의 늦은 응답은 무시합니다.
- **모델과 DTO 분리**: 화면은 `TripCheckDraft`만 다루고, 서버 요청 시에만 지갑/목표 기준 요청 DTO로 변환합니다.

<br>

## 👥 Contributor

<!-- 팀원 사진 / 이름 / 역할 / GitHub -->
| 이름 | 역할 | Github |
| :--- | :--- | :--- |
| 염주원 | - 프로젝트 기획<br>- UXUI 설계<br>- 프론트엔드(flutter) 개발 | [link](https://github.com/HiJuwon) |


<br>

## 🔗 기타

- 📋 PlanB Frontend Kanban: [planB Project Board](https://github.com/orgs/PlanBproject-dev/projects/1)

<!-- ending 이미지 넣기 -->