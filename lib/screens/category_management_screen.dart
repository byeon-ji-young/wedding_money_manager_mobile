import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../models/category.dart';

import '../utils/category_utils.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  List<Category> categories = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadCategories();
  }

  // 카테고리 목록 조회
  Future<void> loadCategories() async {
    final result = await DatabaseHelper.instance.getCategories();

    if (!mounted) {
      return;
    }

    setState(() {
      categories = result;
      isLoading = false;
    });
  }

  Future<void> showAddCategoryDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('카테고리 추가'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '카테고리 이름을 입력해주세요',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) {
                  return;
                }

                await DatabaseHelper.instance.insertCategory(
                  Category(name: name, createdAt: DateTime.now()),
                );

                if (!context.mounted) {
                  return;
                }

                Navigator.pop(context);
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();

      if (mounted) {
        loadCategories();
      }
    });
  }

  Future<void> showEditCategoryDialog(Category category) async {
    final controller = TextEditingController(text: category.name);

    await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text('카테고리 수정'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '카테고리 이름을 입력해주세요',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) {
                  return;
                }

                await DatabaseHelper.instance.updateCategory(
                  Category(
                    id: category.id,
                    name: name,
                    createdAt: category.createdAt,
                  ),
                );

                if (!context.mounted) {
                  return;
                }

                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        );
      }),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();

      if (mounted) {
        loadCategories();
      }
    });
  }

  Future<void> deleteCategory(Category category) async {
    if (category.id == null) {
      return;
    }

    final expenseCount = await DatabaseHelper.instance
        .getExpenseCountByCategory(category.id!);

    if (!mounted) {
      return;
    }

    if (expenseCount > 0) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('카테고리 삭제'),
            content: Text(
              '${category.name} 카테고리를 사용 중인 지출이 '
              '$expenseCount건 있어요.\n\n'
              '사용 중인 카테고리는 삭제할 수 없습니다.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );

      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('카테고리 삭제'),
          content: Text(
            '${category.name} 카테고리를 삭제할까요?\n'
            '삭제한 카테고리는 복구할 수 없습니다.',
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await DatabaseHelper.instance.deleteCategory(category.id!);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${category.name} 카테고리가 삭제되었습니다.')));

    loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        //title: const Text('카테고리 관리'),
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '카테고리 관리',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '지출을 등록할 때 사용할 카테고리를 관리할 수 있어요.',
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: showAddCategoryDialog,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('카테고리 추가'),
                    ),
                  ),

                  // 카테고리 목록 영역만 스크롤
                  Expanded(
                    child: ListView(
                      children: [
                        ...categories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          final isLast = index == categories.length - 1;

                          final categoryColor = getCategoryColor(category.name);

                          return Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
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
                                    getCategoryIcon(category.name),
                                    color: categoryColor,
                                    size: 21,
                                  ),
                                ),
                                title: Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_horiz_rounded),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      showEditCategoryDialog(category);
                                    } else if (value == 'delete') {
                                      deleteCategory(category);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_rounded, size: 20),
                                          SizedBox(width: 12),
                                          Text('수정'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline_rounded,
                                            size: 20,
                                            color: colorScheme.error,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '삭제',
                                            style: TextStyle(
                                              color: colorScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (!isLast)
                                Divider(
                                  height: 1,
                                  indent: 78,
                                  endIndent: 18,
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
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
    );
  }
}
