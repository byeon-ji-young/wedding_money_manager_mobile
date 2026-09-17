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
      appBar: AppBar(
        // title: const Text('전체 지출 내역'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : expenses.isEmpty
          ? const Center(
              child: Text('지출 내역이 없습니다.', style: TextStyle(color: Colors.grey)),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '전체 지출 내역',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '지출 내역을 확인하고 등록하거나 수정할 수 있어요.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExpenseRegisterScreen(),
                          ),
                        );

                        loadExpenses();
                      },
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('지출 추가'),
                    ),
                  ),

                  // 카테고리 목록 영역만 스크롤
                  Expanded(
                    child: ListView(
                      // padding: const EdgeInsets.all(20),
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            // color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            // border: Border.all(
                            //   color: Theme.of(
                            //     context,
                            //   ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                            // ),
                          ),
                          child: Column(
                            children: [
                              ...expenses.asMap().entries.map((entry) {
                                final index = entry.key;
                                final expense = entry.value;

                                final categoryColor = getCategoryColor(
                                  expense.categoryName,
                                );

                                return Column(
                                  children: [
                                    ListTile(
                                      onTap: () async {
                                        // 지출 ID가 없는 경우
                                        if (expense.id == null) {
                                          return;
                                        }

                                        // 지출 ID로 원본 지출 정보 조회
                                        final result = await DatabaseHelper
                                            .instance
                                            .getExpenseById(expense.id!);

                                        // 지출 정보를 찾지 못한 경우
                                        if (result == null ||
                                            !context.mounted) {
                                          return;
                                        }

                                        // 지출 수정 화면으로 이동
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ExpenseRegisterScreen(
                                                  expense: result,
                                                ),
                                          ),
                                        );

                                        // 수정 후 목록 다시 불러오기
                                        loadExpenses();
                                      },
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            // vertical: 4,
                                          ),
                                      leading: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: categoryColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          getCategoryIcon(expense.categoryName),
                                          color: categoryColor,
                                          size: 21,
                                        ),
                                      ),
                                      title: Text(
                                        expense.categoryName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${expense.payer} · '
                                        '${expense.date.year}.'
                                        '${expense.date.month}.'
                                        '${expense.date.day}',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${formatAmount(expense.amount)}원',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Icon(
                                            Icons.chevron_right,
                                            size: 22,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),

                                    if (index != expenses.length - 1)
                                      Divider(
                                        height: 1,
                                        indent: 78,
                                        endIndent: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outlineVariant
                                            .withValues(alpha: 0.5),
                                      ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
