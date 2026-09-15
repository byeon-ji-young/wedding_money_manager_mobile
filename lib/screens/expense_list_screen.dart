import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../models/expense_with_category.dart';

import 'expense_register_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  // 전체 지출 내역
  List<ExpenseWithCategory> expenses = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadExpenses();
  }

  // 전체 지출 내역 불러오기
  Future<void> loadExpenses() async {
    final result = await DatabaseHelper.instance.getAllExpenses();

    if (!mounted) {
      return;
    }

    setState(() {
      expenses = result;
      isLoading = false;
    });
  }

  // 금액을 천 단위 콤마가 포함된 문자열로 변환
  String formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('전체 지출 내역'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : expenses.isEmpty
          ? const Center(
              child: Text('지출 내역이 없습니다.', style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () async {
                      // 지출 ID가 없는 경우
                      if (expense.id == null) {
                        return;
                      }

                      // 지출 ID로 원본 지출 정보 조회
                      final result = await DatabaseHelper.instance
                          .getExpenseById(expense.id!);

                      // 지출 정보를 찾지 못한 경우
                      if (result == null || !context.mounted) {
                        return;
                      }

                      // 지출 수정 화면으로 이동
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExpenseRegisterScreen(expense: result),
                        ),
                      );

                      // 수정 후 목록 다시 불러오기
                      loadExpenses();
                    },
                    leading: Icon(getCategoryIcon(expense.categoryName)),
                    title: Text(
                      expense.categoryName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${expense.payer} · '
                      '${expense.date.year}.'
                      '${expense.date.month}.'
                      '${expense.date.day}',
                    ),
                    trailing: Text(
                      '${formatAmount(expense.amount)}원',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
