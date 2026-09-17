import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../models/expense_with_category.dart';

import '../utils/category_utils.dart';

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
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: getCategoryColor(
                          expense.categoryName,
                        ).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        getCategoryIcon(expense.categoryName),
                        color: getCategoryColor(expense.categoryName),
                      ),
                    ),
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
