class DateTimeUtils {
  // 한국 표준시(KST, UTC+9)
  static DateTime nowKst() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));

    // KST 시각을 일반적인 Local DateTime으로 변환
    return DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );
  }

  // 날짜만 비교하기 위한 KST 오늘 날짜
  static DateTime todayKst() {
    final now = nowKst();

    return DateTime(now.year, now.month, now.day);
  }
}
