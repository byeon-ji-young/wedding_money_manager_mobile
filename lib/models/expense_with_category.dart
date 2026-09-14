class ExpenseWithCategory {
  final int? id; // 지출 고유 번호
  final int amount; // 지출 금액
  final DateTime date; // 지출 날짜
  final String categoryName; // 카테고리 이름
  final String payer; // 지출한 사람
  final String? memo; // 메모

  ExpenseWithCategory({
    this.id,
    required this.amount,
    required this.date,
    required this.categoryName,
    required this.payer,
    this.memo,
  });
}
