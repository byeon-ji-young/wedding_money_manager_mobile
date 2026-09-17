import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../models/category.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('카테고리 관리'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  '지출 카테고리',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  '지출을 등록할 때 사용할 카테고리를 관리할 수 있어요.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 20),

                Card(
                  child: Column(
                    children: [
                      ...categories.map((category) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.folder_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            category.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  showEditCategoryDialog(category);
                                },
                                icon: const Icon(Icons.edit_rounded),
                                tooltip: '카테고리 수정',
                              ),
                              IconButton(
                                onPressed: () {
                                  deleteCategory(category);
                                },
                                icon: const Icon(Icons.delete_outline_rounded),
                                tooltip: '카테고리 삭제',
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddCategoryDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('카테고리 추가'),
      ),
    );
  }
}
