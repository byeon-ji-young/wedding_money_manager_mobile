class Settings {
  final int? id; // 설정 고유 번호
  final String key; // 설정 이름
  final String value; // 설정 값

  Settings({this.id, required this.key, required this.value});

  // Settings 객체를 SQLite에 저장할 수 있는 Map으로 변환
  Map<String, dynamic> toMap() {
    return {'id': id, 'key': key, 'value': value};
  }

  // SQLite의 Map 데이터를 Settings 객체로 변환
  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      id: map['id'] as int?,
      key: map['key'] as String,
      value: map['value'] as String,
    );
  }
}
