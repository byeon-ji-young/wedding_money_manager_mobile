import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:wedding_money_manager_mobile/database/database_helper.dart';

void main() {
  // 테스트 환경에서 SQLite를 사용할 수 있도록 초기화
  sqfliteFfiInit();

  // sqflite가 FFI 데이터베이스를 사용하도록 설정
  databaseFactory = databaseFactoryFfi;

  test('데이터베이스가 정상적으로 생성되는지 확인', () async {
    // 데이터베이스 열기
    final db = await DatabaseHelper.instance.database;

    // categories 테이블이 존재하는지 확인
    final categories = await db.query('categories');

    // 기본 카테고리가 10개 등록되어 있는지 확인
    expect(categories.length, 10);

    // 첫 번째 카테고리가 예식장인지 확인
    expect(categories.first['name'], '예식장');

    // 마지막 카테고리가 기타인지 확인
    expect(categories.last['name'], '기타');
  });
}
