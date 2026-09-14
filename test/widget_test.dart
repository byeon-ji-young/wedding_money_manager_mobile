import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_money_manager_mobile/main.dart';

void main() {
  testWidgets('결혼자금 관리 앱 기본 화면 테스트', (WidgetTester tester) async {
    // 앱을 실행한다.
    await tester.pumpWidget(const WeddingMoneyManagerApp());

    // 앱 제목이 표시되는지 확인한다.
    expect(find.text('우리의 결혼자금'), findsOneWidget);

    // 홈 화면의 문구가 표시되는지 확인한다.
    expect(find.text('💒 결혼자금 관리'), findsOneWidget);
  });
}
