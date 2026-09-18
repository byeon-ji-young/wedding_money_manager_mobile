import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../utils/category_utils.dart';

import 'category_detail_screen.dart';

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

  // 금액을 천 단위 콤마가 포함된 문자열로 변환
  String formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = colorScheme.outlineVariant.withValues(alpha: 0.5);

    // 예산 대비 전체 지출 비율
    final expenseRate = budget == null || budget == 0
        ? null
        : totalExpense / budget!;

    // 남은 예산
    final remainBudget = budget == null ? null : budget! - totalExpense;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categorySummary.isEmpty
          ? const Center(
              child: Text(
                '아직 지출 내역이 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 화면 제목
                  const Text(
                    '지출 통계',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '우리의 결혼자금 지출 현황을 한눈에 확인할 수 있어요.',
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 전체 지출 요약
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              size: 20,
                              color: colorScheme.primary,
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

                        const SizedBox(height: 20),

                        Text(
                          '${formatAmount(totalExpense)}원',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (budget != null) ...[
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '예산 ${formatAmount(budget!)}원',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${(expenseRate! * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: expenseRate.clamp(0.0, 1.0),
                              minHeight: 8,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            remainBudget! >= 0
                                ? '남은 예산 ${formatAmount(remainBudget)}원'
                                : '예산을 ${formatAmount(remainBudget.abs())}원 초과했어요.',
                            style: TextStyle(
                              fontSize: 14,
                              color: remainBudget >= 0
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.error,
                            ),
                          ),
                        ],

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

                  const SizedBox(height: 24),

                  // 카테고리별 지출
                  const Text(
                    '카테고리별 지출',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      // border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        ...categorySummary.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          final categoryName = item['categoryName'] as String;
                          final totalAmount = item['totalAmount'] as int;

                          final percentage = totalExpense == 0
                              ? 0.0
                              : totalAmount / totalExpense;

                          final categoryColor = getCategoryColor(categoryName);

                          return Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  final categoryId = item['categoryId'] as int;

                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CategoryDetailScreen(
                                            categoryId: categoryId,
                                            categoryName: categoryName,
                                            totalAmount: totalAmount,
                                          ),
                                    ),
                                  );

                                  await loadStatistics();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: categoryColor.withValues(
                                                alpha: 0.12,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              getCategoryIcon(categoryName),
                                              color: categoryColor,
                                              size: 21,
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Text(
                                              categoryName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),

                                          Text(
                                            '${formatAmount(totalAmount)}원',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: LinearProgressIndicator(
                                                value: percentage,
                                                minHeight: 7,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          SizedBox(
                                            width: 48,
                                            child: Text(
                                              '${(percentage * 100).toStringAsFixed(1)}%',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              if (index != categorySummary.length - 1)
                                Divider(
                                  height: 1,
                                  indent: 18,
                                  endIndent: 18,
                                  color: borderColor,
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 월별 지출
                  const Text(
                    '월별 지출',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      // border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        ...monthlySummary.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          final month = item['month'] as String;
                          final totalAmount = item['totalAmount'] as int;

                          final percentage = totalExpense == 0
                              ? 0.0
                              : totalAmount / totalExpense;

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month_rounded,
                                          size: 22,
                                          color: colorScheme.primary,
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: Text(
                                            '${month.substring(0, 4)}년 '
                                            '${int.parse(month.substring(5, 7))}월',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),

                                        Text(
                                          '${formatAmount(totalAmount)}원',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: percentage,
                                              minHeight: 7,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        SizedBox(
                                          width: 48,
                                          child: Text(
                                            '${(percentage * 100).toStringAsFixed(1)}%',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              if (index != monthlySummary.length - 1)
                                Divider(
                                  height: 1,
                                  indent: 18,
                                  endIndent: 18,
                                  color: borderColor,
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
