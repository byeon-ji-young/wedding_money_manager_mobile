import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/category.dart';
import '../models/expense.dart';
import '../models/expense_with_category.dart';
import '../models/settings.dart';

import '../utils/date_time_utils.dart';

class DatabaseHelper {
  // 데이터베이스 파일 이름
  static const String _databaseName = 'wedding_money_manager.db';

  // 데이터베이스 버전
  static const int _databaseVersion = 1;

  // 싱글톤 인스턴스
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // 실제 데이터베이스 객체
  static Database? _database;

  // 외부에서 직접 생성하지 못하도록 막음
  DatabaseHelper._internal();

  // 데이터베이스를 가져오기
  Future<Database> get database async {
    // 이미 데이터베이스가 열려 있다면 그대로 사용
    if (_database != null) {
      return _database!;
    }

    // 데이터베이스가 없다면 새로 열기
    _database = await _initDatabase();

    return _database!;
  }

  // 데이터베이스를 초기화
  Future<Database> _initDatabase() async {
    // 앱에서 사용할 데이터베이스 파일 경로 생성
    final databasePath = await getDatabasesPath();

    final path = join(databasePath, _databaseName);

    // 데이터베이스를 열고 테이블을 생성
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // 데이터베이스가 처음 만들어질 때 실행된다.
  Future<void> _onCreate(Database db, int version) async {
    // 1. 카테고리 테이블
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // 2. 지출 테이블
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER NOT NULL,
        date TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        payer TEXT NOT NULL,
        memo TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // 3. 설정 테이블
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT NOT NULL UNIQUE,
        value TEXT NOT NULL
      )
    ''');

    // 4. 기본 카테고리 등록
    final now = DateTime.now().toIso8601String();

    final defaultCategories = [
      '예식장',
      '스드메',
      '스냅영상',
      '맞춤정장',
      '예물',
      '신혼여행',
      '가전',
      '가구',
      '생활용품',
      '기타',
    ];

    for (final category in defaultCategories) {
      await db.insert('categories', {'name': category, 'createdAt': now});
    }
  }

  // ========================================================= categories =========================================================
  // 카테고리 전체 조회
  Future<List<Category>> getCategories() async {
    final db = await database;

    final maps = await db.query('categories', orderBy: 'id ASC');

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  // 카테고리 추가
  Future<int> insertCategory(Category category) async {
    final db = await database;

    return await db.insert('categories', category.toMap());
  }

  // 카테고리 수정
  Future<int> updateCategory(Category category) async {
    final db = await database;

    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // 카테고리 삭제
  Future<int> deleteCategory(int id) async {
    final db = await database;

    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ========================================================= expenses =========================================================
  // 지출 전체 조회
  Future<List<Expense>> getExpenses() async {
    final db = await database;

    final maps = await db.query('expenses', orderBy: 'date DESC');

    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  // 지출 추가
  Future<int> insertExpense(Expense expense) async {
    final db = await database;

    return await db.insert('expenses', expense.toMap());
  }

  // 지출 수정
  Future<int> updateExpense(Expense expense) async {
    final db = await database;

    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // 지출 삭제
  Future<int> deleteExpense(int id) async {
    final db = await database;

    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // 전체 지출 금액 조회
  Future<int> getTotalExpense() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM expenses',
    );

    final total = result.first['total'];

    // 지출 내역이 없으면 0 반환
    return total == null ? 0 : total as int;
  }

  // 이번 달 지출 금액 조회
  Future<int> getMonthlyExpense() async {
    final db = await database;

    final now = DateTimeUtils.nowKst();

    // 이번 달의 시작 날짜
    final startDate = DateTime(now.year, now.month, 1);

    // 다음 달의 시작 날짜
    final endDate = DateTime(now.year, now.month + 1, 1);

    final result = await db.rawQuery(
      '''
        SELECT SUM(amount) AS total
        FROM expenses
        WHERE date >= ? AND date < ?
      ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    final total = result.first['total'];

    // 이번 달 지출이 없으면 0 반환
    return total == null ? 0 : total as int;
  }

  // 최근 지출 내역 조회
  Future<List<ExpenseWithCategory>> getRecentExpenses() async {
    final db = await database;

    final result = await db.rawQuery(''' 
        SELECT 
          expenses.id, 
          expenses.amount, 
          expenses.date, 
          categories.name AS categoryName, 
          expenses.payer, 
          expenses.memo 
        FROM expenses 
        INNER JOIN categories 
          ON expenses.categoryId = categories.id 
        ORDER BY expenses.date DESC, expenses.id DESC 
        LIMIT 5 
      ''');

    return result.map((map) {
      return ExpenseWithCategory(
        id: map['id'] as int?,
        amount: map['amount'] as int,
        date: DateTime.parse(map['date'] as String),
        categoryName: map['categoryName'] as String,
        payer: map['payer'] as String,
        memo: map['memo'] as String?,
      );
    }).toList();
  }

  // ========================================================= settings =========================================================
  // 설정 전체 조회
  Future<List<Settings>> getSettings() async {
    final db = await database;

    final maps = await db.query('settings', orderBy: 'id ASC');

    return maps.map((map) => Settings.fromMap(map)).toList();
  }

  // 설정 조회
  Future<Settings?> getSetting(String key) async {
    final db = await database;

    final maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Settings.fromMap(maps.first);
  }

  // 설정 추가
  Future<int> insertSetting(Settings setting) async {
    final db = await database;

    return await db.insert('settings', setting.toMap());
  }

  // 설정 수정
  Future<int> updateSetting(Settings setting) async {
    final db = await database;

    return await db.update(
      'settings',
      setting.toMap(),
      where: 'id = ?',
      whereArgs: [setting.id],
    );
  }

  // 설정 삭제
  Future<int> deleteSetting(int id) async {
    final db = await database;

    return await db.delete('settings', where: 'id = ?', whereArgs: [id]);
  }

  // 예산 조회
  Future<int?> getBudget() async {
    final setting = await getSetting('budget');

    if (setting == null) {
      return null;
    }

    return int.tryParse(setting.value);
  }
}
