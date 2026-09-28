import 'package:flutter/material.dart';

// 결제수단별 아이콘
IconData getPaymentMethodIcon(String paymentMethod) {
  switch (paymentMethod) {
    case '신용카드':
      return Icons.credit_card_rounded;
    case '체크카드':
      return Icons.credit_score_rounded;
    case '계좌이체':
      return Icons.account_balance_rounded;
    case '현금':
      return Icons.payments_rounded;
    default:
      return Icons.credit_card_rounded;
  }
}

// 결제수단별 색상
Color getPaymentMethodColor(String paymentMethod) {
  switch (paymentMethod) {
    case '신용카드':
      return Colors.blue;
    case '체크카드':
      return Colors.teal;
    case '계좌이체':
      return Colors.indigo;
    case '현금':
      return Colors.green;
    default:
      return Colors.grey;
  }
}
