class Category {
  final int? id; // 카테고리 고유 번호
  final String name; // 카테고리 이름
  final DateTime createdAt; // 카테고리가 생성된 시간

  Category({this.id, required this.name, required this.createdAt});

  // Category 객체를 SQLite에 저장할 수 있는 Map으로 변환
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'createdAt': createdAt.toIso8601String()};
  }

  // SQLite의 Map 데이터를 Category 객체로 변환
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
