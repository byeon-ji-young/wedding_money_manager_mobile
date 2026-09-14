class Expense {
  final int? id; // 지출 고유 번호
  final int amount; // 지출 금액
  final DateTime date; // 지출 날짜
  final int categoryId; // 지출 카테고리 번호
  final String payer; // 지출한 사람
  final String? memo; // 메모
  final DateTime createdAt; // 데이터가 생성된 시간

  Expense({
    this.id,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.payer,
    this.memo,
    required this.createdAt,
  });

  // Expense 객체를 SQLite에 저장할 수 있는 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'payer': payer,
      'memo': memo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // SQLite의 Map 데이터를 Expense 객체로 변환
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: map['amount'] as int,
      date: DateTime.parse(map['date'] as String),
      categoryId: map['categoryId'] as int,
      payer: map['payer'] as String,
      memo: map['memo'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
