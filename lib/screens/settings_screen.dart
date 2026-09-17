import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/settings.dart';
import 'category_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int? budget;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadBudget();
  }

  // 예산 조회
  Future<void> loadBudget() async {
    final result = await DatabaseHelper.instance.getBudget();

    if (!mounted) {
      return;
    }

    setState(() {
      budget = result;
      isLoading = false;
    });
  }

  // 금액에 콤마 표시
  String formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  // 예산 설정 다이얼로그
  Future<void> showBudgetDialog() async {
    final budgetController = TextEditingController(
      text: budget?.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) {
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
                    final value = int.tryParse(budgetController.text);

                    if (value == null || value <= 0) {
                      setDialogState(() {
                        errorMessage = '올바른 금액을 입력해주세요.';
                      });
                      return;
                    }

                    if (budget == null) {
                      await DatabaseHelper.instance.insertSetting(
                        Settings(key: 'budget', value: value.toString()),
                      );
                    } else {
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

    // 다이얼로그가 완전히 닫힌 다음 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      budgetController.dispose();

      if (mounted) {
        loadBudget();
      }
    });
  }

  // 전체 데이터 초기화
  Future<void> resetAllData() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('전체 데이터 초기화'),
          content: const Text(
            '모든 지출 내역과 예산 설정이 삭제됩니다.\n'
            '추가한 카테고리도 삭제되고 기본 카테고리만 남습니다.\n\n'
            '정말 초기화하시겠어요?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('초기화'),
            ),
          ],
        );
      },
    );

    // 초기화를 취소한 경우
    if (shouldReset != true) {
      return;
    }

    // 데이터 초기화
    await DatabaseHelper.instance.clearAllData();

    if (!mounted) {
      return;
    }

    // 설정 화면의 예산 정보 새로고침
    await loadBudget();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('모든 데이터가 초기화되었습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  '관리',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // 예산 설정
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet_rounded),
                    title: const Text('예산 설정'),
                    subtitle: Text(
                      budget == null
                          ? '아직 예산이 설정되지 않았어요.'
                          : '현재 ${formatAmount(budget!)}원',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: showBudgetDialog,
                  ),
                ),

                const SizedBox(height: 12),

                // 카테고리 관리
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.category_rounded),
                    title: const Text('카테고리 관리'),
                    subtitle: const Text('지출 카테고리를 추가하거나 수정할 수 있어요.'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CategoryManagementScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.delete_forever_rounded),
                    title: const Text('전체 데이터 초기화'),
                    subtitle: const Text('모든 지출 내역과 설정을 삭제합니다.'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: resetAllData,
                  ),
                ),
              ],
            ),
    );
  }
}
