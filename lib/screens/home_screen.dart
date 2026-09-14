import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../models/expense_with_category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? budget;
  int totalExpense = 0;
  int monthlyExpense = 0;

  // 최근 지출 내역
  List<ExpenseWithCategory> recentExpenses = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    final result = await Future.wait([
      DatabaseHelper.instance.getBudget(),
      DatabaseHelper.instance.getTotalExpense(),
      DatabaseHelper.instance.getMonthlyExpense(),
      DatabaseHelper.instance.getRecentExpenses(),
    ]);

    // 화면이 아직 존재할 때만 상태 변경
    if (!mounted) {
      return;
    }

    setState(() {
      budget = result[0] as int?;
      totalExpense = result[1] as int;
      monthlyExpense = result[2] as int;
      recentExpenses = result[3] as List<ExpenseWithCategory>;

      // 데이터 로딩 완료
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
    // 남은 예산
    final remainBudget = budget == null ? null : budget! - totalExpense;

    // 예산 대비 전체 지출 비율
    final expenseRate = budget == null || budget == 0
        ? null
        : totalExpense / budget! * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('우리의 결혼자금'),
        actions: [
          IconButton(
            onPressed: () async {
              // 추후
            },
            icon: const Icon(Icons.settings_outlined, size: 22),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 예산, 지출, 남은금액
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '총 예산',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            budget == null
                                ? '예산을 설정해주세요'
                                : '${formatAmount(budget!)}원',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            '총 지출',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            '${formatAmount(totalExpense)}원',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            '남은 금액',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            remainBudget == null
                                ? '-'
                                : '${formatAmount(remainBudget)}원',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            '이번 달 지출',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            '${formatAmount(monthlyExpense)}원',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            '지출률',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            expenseRate == null
                                ? '-'
                                : '${expenseRate.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 최근 지출
                  const Text(
                    '최근 지출',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  if (recentExpenses.isEmpty)
                    const Text(
                      '아직 지출 내역이 없습니다.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ...recentExpenses.map((expense) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            expense.categoryName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${expense.payer} · ${expense.date.year}.${expense.date.month}.${expense.date.day}',
                          ),
                          trailing: Text(
                            '${formatAmount(expense.amount)}원',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
