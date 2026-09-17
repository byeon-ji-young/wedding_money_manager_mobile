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

  // 설정 메뉴 아이콘
  Widget buildMenuIcon({required IconData icon, bool isDanger = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    final color = isDanger ? colorScheme.error : colorScheme.primary;

    final backgroundColor = isDanger
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 21),
    );
  }

  // 설정 메뉴 하나
  Widget buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
    bool showDivider = true,
    String? trailingText,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 2,
          ),
          leading: buildMenuIcon(icon: icon, isDanger: isDanger),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          trailing: trailingText != null
              ? Text(
                  trailingText,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              : const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 78,
            endIndent: 18,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }

  // 설정 섹션
  Widget buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip
              .antiAlias, //  Clip.antiAlias는 위젯의 영역 밖으로 삐져나오는 부분을 잘라내되, 경계선을 부드럽게 처리하라는 의미
          child: Column(children: children),
        ),
      ],
    );
  }

  Future<void> openCategoryManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoryManagementScreen()),
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
            final colorScheme = Theme.of(context).colorScheme;

            return AlertDialog(
              title: const Text(
                '예산 설정',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '결혼 준비에 사용할 전체 예산을 설정해주세요.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '예: 50,000,000',
                      suffixText: '원',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colorScheme.secondary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),

                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  ],
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('취소'),
                ),
                TextButton(
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
          // title: const Text('전체 데이터 초기화'),
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
            TextButton(
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

    // 설정 화면의 예산 정보 새로고침
    await loadBudget();

    // 다이얼로그가 닫힌 후에도 화면이 존재하는지 확인
    if (!mounted) {
      return;
    }

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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                buildSection(
                  title: '관리',
                  children: [
                    buildSettingTile(
                      icon: Icons.account_balance_wallet_rounded,
                      title: '예산 설정',
                      subtitle: budget == null
                          ? '아직 예산이 설정되지 않았어요.'
                          : '${formatAmount(budget!)}원',
                      onTap: showBudgetDialog,
                    ),
                    buildSettingTile(
                      icon: Icons.category_rounded,
                      title: '카테고리 관리',
                      subtitle: '지출 카테고리를 추가하거나 수정할 수 있어요.',
                      onTap: openCategoryManagement,
                    ),
                    buildSettingTile(
                      icon: Icons.delete_forever_rounded,
                      title: '전체 데이터 초기화',
                      subtitle: '모든 지출 내역과 설정을 삭제해요.',
                      onTap: resetAllData,
                      isDanger: true,
                      showDivider: false,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                buildSection(
                  title: '앱 정보',
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 2,
                      ),
                      leading: buildMenuIcon(icon: Icons.info_outline_rounded),
                      title: const Text(
                        '앱 정보',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Text(
                        'ver 1.0.0',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
