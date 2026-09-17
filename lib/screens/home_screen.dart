import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../models/expense_with_category.dart';
import '../models/settings.dart';

import '../utils/category_utils.dart';

import 'expense_register_screen.dart';
import 'expense_list_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? budget;
  int totalExpense = 0;
  int monthlyExpense = 0;
  int expenseCount = 0;

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
      DatabaseHelper.instance.getExpenseCount(),
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
      expenseCount = result[4] as int;

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

  // 예산 설정 Dialog
  Future<void> showBudgetDialog() async {
    // 예산을 입력받기 위한 컨트롤러
    final budgetController = TextEditingController(
      text: budget?.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) {
        // 에러 메시지
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('예산 설정 💕'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '예산을 입력해주세요',
                      suffixText: '원',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  // 에러 메시지
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 입력한 예산을 숫자로 변환
                    final value = int.tryParse(budgetController.text);

                    // 잘못된 값이면 에러 메시지 표시
                    if (value == null || value <= 0) {
                      setDialogState(() {
                        errorMessage = '올바른 금액을 입력해주세요.';
                      });

                      return;
                    }

                    // 기존 예산이 없는 경우
                    if (budget == null) {
                      await DatabaseHelper.instance.insertSetting(
                        Settings(key: 'budget', value: value.toString()),
                      );
                    }
                    // 기존 예산이 있는 경우
                    else {
                      final setting = await DatabaseHelper.instance.getSetting(
                        'budget',
                      );

                      if (setting != null) {
                        await DatabaseHelper.instance.updateSetting(
                          Settings(
                            id: setting.id,
                            key: 'budget',
                            value: value.toString(),
                          ),
                        );
                      }
                    }

                    // 저장이 끝나면 Dialog 닫기
                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(context);
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );

    // Dialog가 완전히 닫힌 다음 컨트롤러 정리 및 홈 데이터 갱신
    WidgetsBinding.instance.addPostFrameCallback((_) {
      budgetController.dispose();

      if (mounted) {
        loadData();
      }
    });
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
        // title: const Text('우리의 결혼자금'),
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: '지출 통계',
          ),

          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );

              if (mounted) {
                loadData();
              }
            },
            icon: const Icon(Icons.settings_rounded),
            tooltip: '설정',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  // vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          // 예산 요약
                          Container(
                            width: double.infinity,
                            // padding: const EdgeInsets.symmetric(
                            //   horizontal: 24,
                            //   vertical: 10,
                            // ),
                            decoration: BoxDecoration(
                              //color: Theme.of(context).colorScheme.surfaceContainerLow,
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              // border: Border.all(
                              //   color: Theme.of(context).colorScheme.outlineVariant,
                              // ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 제목
                                Row(
                                  children: [
                                    Icon(
                                      Icons.favorite_rounded,
                                      size: 20,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),

                                    const SizedBox(width: 8),

                                    Text(
                                      '우리의 결혼자금',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // 총 예산
                                const Text(
                                  '총 예산',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                InkWell(
                                  onTap: showBudgetDialog,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        budget == null
                                            ? '예산을 설정해주세요'
                                            : '${formatAmount(budget!)}원',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      if (budget != null) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.edit_rounded,
                                          size: 18,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // 진행률
                                if (expenseRate != null) ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        '현재까지 사용한 금액',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      Text(
                                        '${expenseRate.toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: (expenseRate / 100).clamp(
                                        0.0,
                                        1.0,
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                ],

                                // 남은 금액
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '남은 금액',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),

                                    Text(
                                      remainBudget == null
                                          ? '-'
                                          : '${formatAmount(remainBudget)}원',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          Divider(
                            height: 1,
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                            // height: 1,
                          ),

                          const SizedBox(height: 20),

                          // 이번 달 지출 / 전체 지출
                          Row(
                            children: [
                              // 전체 지출
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      '전체 지출',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${formatAmount(totalExpense)}원',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 이번달 지출
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_month_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      '이번 달 지출',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${formatAmount(monthlyExpense)}원',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 최근 지출
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 최근 지출 + 전체 건수
                        Row(
                          children: [
                            const Text(
                              '최근 지출',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              '총 $expenseCount건',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),

                        // 지출이 5건을 초과하면 전체보기 표시
                        if (expenseCount > 5)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ExpenseListScreen(),
                                ),
                              );
                            },
                            child: const Text('전체보기'),
                          ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    if (recentExpenses.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '아직 지출 내역이 없습니다.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          children: [
                            ...recentExpenses.asMap().entries.map((entry) {
                              final index = entry.key;
                              final expense = entry.value;

                              return Column(
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 4,
                                    ),
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
                                        color: getCategoryColor(
                                          expense.categoryName,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      expense.categoryName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${expense.payer} · '
                                      '${expense.date.year}.'
                                      '${expense.date.month}.'
                                      '${expense.date.day}',
                                    ),
                                    trailing: Text(
                                      '${formatAmount(expense.amount)}원',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  if (index != recentExpenses.length - 1)
                                    Divider(
                                      height: 1,
                                      indent: 20,
                                      endIndent: 20,
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
            ),

      // 하단 지출 등록 버튼
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExpenseRegisterScreen(),
                  ),
                );

                // 등록 화면에서 돌아오면 홈 데이터 다시 불러오기
                loadData();
              },
              icon: const Icon(Icons.add_rounded, size: 24),
              label: const Text(
                '지출 추가',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
