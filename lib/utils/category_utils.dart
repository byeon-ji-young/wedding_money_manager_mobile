import 'package:flutter/material.dart';

IconData getCategoryIcon(String categoryName) {
  switch (categoryName) {
    case '예식장':
      // return Icons.location_city_rounded;
      return Icons.celebration_rounded;

    case '스드메':
      return Icons.checkroom_rounded;

    case '스냅/영상':
      return Icons.photo_camera_rounded;

    case '맞춤정장':
      // return Icons.business_center_rounded;
      return Icons.man_rounded;

    case '예물':
      return Icons.diamond_rounded;

    case '신혼여행':
      return Icons.flight_rounded;

    case '가전':
      // return Icons.tv_rounded;
      return Icons.kitchen_rounded;

    case '가구':
      return Icons.chair_rounded;

    case '생활용품':
      return Icons.home_rounded;

    case '기타':
      return Icons.receipt_long_rounded;

    default:
      return Icons.receipt_long_rounded;
  }
}

Color getCategoryColor(String categoryName) {
  switch (categoryName) {
    case '예식장':
      return Colors.pink;

    case '스드메':
      return Colors.purple;

    case '스냅/영상':
      return Colors.teal;

    case '맞춤정장':
      return Colors.indigo;

    case '예물':
      return Colors.amber;

    case '신혼여행':
      return Colors.lightBlue;

    case '가전':
      return Colors.orange;

    case '가구':
      return Colors.brown;

    case '생활용품':
      return Colors.green;

    case '기타':
      return Colors.grey;

    default:
      return Colors.grey;
  }
}
