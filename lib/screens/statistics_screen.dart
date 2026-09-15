import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // 카테고리 지출 합계
  List<Map<String, dynamic>> categorySummary = [];
  // 월별 지출 합계
  List<Map<String, dynamic>> monthlySummary = [];
  // 전체 지출 금액
  int totalExpense = 0;
  // 전체 예산
  int? budget;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadStatistics();
  }

  Future<void> loadStatistics() async {
    try {
      final result = await Future.wait([
        DatabaseHelper.instance.getExpenseSummaryByCategory(),
        DatabaseHelper.instance.getTotalExpense(),
        DatabaseHelper.instance.getBudget(),
        DatabaseHelper.instance.getMonthlyExpenseSummary(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        categorySummary = result[0] as List<Map<String, dynamic>>;
        totalExpense = result[1] as int;
        budget = result[2] as int?;
        monthlySummary = result[3] as List<Map<String, dynamic>>;

        isLoading = false;
      });
    } catch (e) {
      debugPrint('통계 불러오기 오류: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  String formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseRate = budget == null || budget == 0
        ? null
        : totalExpense / budget!;

    final remainBudget = budget == null ? null : budget! - totalExpense;

    return Scaffold(
      appBar: AppBar(title: const Text('지출 통계')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categorySummary.isEmpty
          ? const Center(child: Text('아직 지출 내역이 없습니다.'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 전체 지출 요약 카드
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Row(
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '총 지출',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 총 지출 금액
                      Text(
                        '${formatAmount(totalExpense)}원',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // 예산이 설정되어 있는 경우
                      if (budget != null) ...[
                        const SizedBox(height: 24),

                        // 예산 금액 + 지출 비율
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '예산 ${formatAmount(budget!)}원',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              '${(expenseRate! * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 예산 대비 지출 비율
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: expenseRate.clamp(0.0, 1.0),
                            minHeight: 10,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 남은 예산 / 초과 금액
                        Text(
                          remainBudget! >= 0
                              ? '남은 예산 ${formatAmount(remainBudget)}원'
                              : '예산을 ${formatAmount(remainBudget.abs())}원 초과했어요.',
                          style: TextStyle(
                            fontSize: 14,
                            color: remainBudget >= 0
                                ? Colors.grey.shade700
                                : Colors.red,
                          ),
                        ),
                      ],

                      // 예산이 설정되지 않은 경우
                      if (budget == null) ...[
                        const SizedBox(height: 12),
                        const Text(
                          '아직 예산이 설정되지 않았어요.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // 카테고리별 지출
                const Text(
                  '카테고리별 지출',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                ...categorySummary.map((item) {
                  final categoryName = item['categoryName'] as String;
                  final totalAmount = item['totalAmount'] as int;
                  final percentage = totalExpense == 0
                      ? 0
                      : totalAmount / totalExpense * 100;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 카테고리 이름
                          Text(
                            categoryName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 금액 + 비율
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${formatAmount(totalAmount)}원',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // 카테고리별 지출 비율 막대
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: totalExpense == 0
                                  ? 0
                                  : totalAmount / totalExpense,
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                const Text(
                  '월별 지출',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                ...monthlySummary.map((item) {
                  final month = item['month'] as String;
                  final totalAmount = item['totalAmount'] as int;

                  final percentage = totalExpense == 0
                      ? 0.0
                      : totalAmount / totalExpense;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 월
                          Text(
                            '${month.substring(0, 4)}년 ${int.parse(month.substring(5, 7))}월',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 금액 + 전체 지출 대비 비율
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${formatAmount(totalAmount)}원',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(percentage * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // 월별 지출 비율 막대
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: percentage,
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
