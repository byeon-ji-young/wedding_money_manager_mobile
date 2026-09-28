# 결혼자금관리

결혼 준비 과정에서 발생하는 지출을 기록하고 관리할 수 있는 모바일 앱입니다.

예산을 설정하고 지출 내역을 체계적으로 관리하며, 카테고리·결제수단·월별 통계를 통해 결혼자금 지출 현황을 한눈에 확인할 수 있습니다.

## 주요 기능

### 💰 예산 관리

* 총 예산 설정 및 수정
* 총 지출 및 남은 예산 확인
* 예산 대비 지출 비율 확인

### 📝 지출 관리

* 지출 내역 등록
* 지출 내역 수정 및 삭제
* 금액 천 단위 콤마 자동 표시
* 날짜 및 메모 입력
* 결제자 구분
* 결제수단 선택

  * 신용카드
  * 체크카드
  * 계좌이체
  * 현금

### 🗂️ 카테고리 관리

* 결혼 준비 지출 카테고리 관리
* 카테고리별 지출 금액 확인
* 카테고리별 상세 지출 내역 조회

### 🔍 지출 검색

* 카테고리 검색
* 결제자 검색
* 메모 검색

### 📊 지출 통계

* 전체 지출 현황
* 카테고리별 지출 통계
* 결제수단별 지출 통계
* 월별 지출 통계
* 예산 대비 지출 비율 확인

### 💾 데이터 백업 및 복원

* 지출 및 설정 데이터 백업
* 백업 파일을 이용한 데이터 복원
* 기존 백업 데이터와의 호환 처리

## 기술 스택

* Flutter
* Dart
* SQLite
* sqflite
* Material 3

## 개발 환경

* Flutter 3.44.9
* Dart 3.12.2
* Android SDK 36

## 프로젝트 구조

```text
lib/
├── main.dart
│
├── database/
│   └── database_helper.dart
│
├── models/
│   ├── category.dart
│   ├── expense.dart
│   ├── expense_with_category.dart
│   └── settings.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── expense_register_screen.dart
│   ├── expense_list_screen.dart
│   ├── statistics_screen.dart
│   ├── category_detail_screen.dart
│   ├── category_management_screen.dart
│   └── settings_screen.dart
│
├── widgets/
│   └── budget_dialog.dart
│
└── utils/
    ├── category_utils.dart
    ├── payment_method_utils.dart
    └── date_time_utils.dart
```

## 실행 방법

### 1. 프로젝트 클론

```bash
git clone https://github.com/byeon-ji-young/wedding_money_manager_mobile.git
cd wedding_money_manager_mobile
```

### 2. 패키지 설치

```bash
flutter pub get
```

### 3. 앱 실행

```bash
flutter run
```

## 화면 미리보기

추후 실제 앱 화면을 추가할 예정입니다.

## 버전

**v1.0.0**

첫 번째 정식 버전입니다.
