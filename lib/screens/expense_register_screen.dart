import 'package:flutter/material.dart';
import 'package:wedding_money_manager_mobile/models/expense.dart';

import '../utils/date_time_utils.dart';
import '../database/database_helper.dart';
import '../models/category.dart';

class ExpenseRegisterScreen extends StatefulWidget {
  // 수정할 지출
  final Expense? expense;

  const ExpenseRegisterScreen({super.key, this.expense});

  @override
  State<ExpenseRegisterScreen> createState() => _ExpenseRegisterScreenState();
}

class _ExpenseRegisterScreenState extends State<ExpenseRegisterScreen> {
  // 금액 입력
  final amountController = TextEditingController();
  // 메모 입력
  final memoController = TextEditingController();
  // 선택한 날짜
  DateTime selectedDate = DateTime.now();
  // 선택한 카테고리
  int? selectedCategoryId;
  // 선택한 결제자
  String selectedPayer = '나';
  // 카테고리 목록
  List<Category> categories = [];
  // 등록, 수정 판단
  bool get isEditMode => widget.expense != null;

  @override
  void initState() {
    super.initState();

    // 수정 모드라면 기존 지출 정보를 입력값에 넣기
    if (isEditMode) {
      amountController.text = widget.expense!.amount.toString();
      memoController.text = widget.expense!.memo ?? '';

      selectedDate = widget.expense!.date;
      selectedCategoryId = widget.expense!.categoryId;
      selectedPayer = widget.expense!.payer;
    }

    loadCategories();
  }

  @override
  void dispose() {
    amountController.dispose();
    memoController.dispose();

    super.dispose();
  }

  // 카테고리 목록 불러오기
  Future<void> loadCategories() async {
    final result = await DatabaseHelper.instance.getCategories();

    if (!mounted) {
      return;
    }

    setState(() {
      categories = result;

      // 처음에는 첫 번째 카테고리를 선택
      if (categories.isNotEmpty && !isEditMode) {
        selectedCategoryId = categories.first.id;
      }
    });
  }

  // 지출 저장
  Future<void> saveExpense() async {
    // 입력한 금액을 숫자로 변환
    final amount = int.tryParse(amountController.text.replaceAll(',', ''));

    // 금액이 잘못 입력된 경우
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('금액을 입력해주세요.')));

      return;
    }

    // 카테고리가 선택되지 않은 경우
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('카테고리를 선택해주세요.')));

      return;
    }

    // 지출 객체 생성
    final expense = Expense(
      id: widget.expense?.id,
      amount: amount,
      date: selectedDate,
      categoryId: selectedCategoryId!,
      payer: selectedPayer,
      memo: memoController.text.trim().isEmpty
          ? null
          : memoController.text.trim(),
      createdAt: widget.expense?.createdAt ?? DateTimeUtils.nowKst(),
    );

    // 수정 모드라면 기존 지출 수정
    if (isEditMode) {
      await DatabaseHelper.instance.updateExpense(expense);
    }
    // 등록 모드라면 새로운 지출 등록
    else {
      await DatabaseHelper.instance.insertExpense(expense);
    }

    // 화면이 이미 종료된 경우 중단
    if (!mounted) return;

    // 저장 완료 안내
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isEditMode ? '지출이 수정되었습니다.' : '지출이 등록되었습니다.')),
    );

    // 이전 화면으로 돌아가기
    Navigator.pop(context);
  }

  // 지출 삭제
  Future<void> deleteExpense() async {
    // 삭제할 지출 ID가 없는 경우
    if (widget.expense?.id == null) {
      return;
    }

    // 삭제 확인
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          // title: const Text('지출 삭제'),
          content: const Text('이 지출을 삭제할까요?\n삭제한 지출은 복구할 수 없습니다.'),
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

    // 삭제하지 않으면 종료
    if (shouldDelete != true) {
      return;
    }

    // DB에서 지출 삭제
    await DatabaseHelper.instance.deleteExpense(widget.expense!.id!);

    if (!mounted) {
      return;
    }

    // 삭제 완료 메시지
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('지출이 삭제되었습니다.')));

    // 이전 화면으로 돌아가기
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? '지출 수정' : '지출 등록'),
        centerTitle: true,
        actions: [
          if (isEditMode)
            IconButton(
              onPressed: deleteExpense,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 22,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 금액
            const Text(
              '금액',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      decoration: const InputDecoration(
                        hintText: '금액을 입력해주세요',
                        hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Text(
                    '원',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 날짜
            const Text(
              '날짜',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (pickedDate == null) {
                  return;
                }

                setState(() {
                  selectedDate = pickedDate;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedDate.year}.${selectedDate.month}.${selectedDate.day}',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 카테고리
            const Text(
              '카테고리',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<int>(
              initialValue: selectedCategoryId,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 1.5),
                ),
              ),
              items: categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // 결제자
            const Text(
              '결제자',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: SizedBox(
                      width: double.infinity,
                      child: Text(
                        '나',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedPayer == '나'
                              ? primaryColor
                              : Colors.black87,
                        ),
                      ),
                    ),
                    selected: selectedPayer == '나',
                    selectedColor: primaryColor.withValues(alpha: 0.15),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: selectedPayer == '나'
                          ? primaryColor
                          : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (selected) {
                      if (!selected) return;
                      setState(() {
                        selectedPayer = '나';
                      });
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ChoiceChip(
                    label: SizedBox(
                      width: double.infinity,
                      child: Text(
                        '배우자',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedPayer == '배우자'
                              ? primaryColor
                              : Colors.black87,
                        ),
                      ),
                    ),
                    selected: selectedPayer == '배우자',
                    selectedColor: primaryColor.withValues(alpha: 0.15),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: selectedPayer == '배우자'
                          ? primaryColor
                          : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (selected) {
                      if (!selected) return;
                      setState(() {
                        selectedPayer = '배우자';
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 메모
            const Text(
              '메모',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: memoController,
              decoration: InputDecoration(
                hintText: '메모를 입력해주세요',
                hintStyle: const TextStyle(color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),

      // 하단 고정 저장 버튼
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: saveExpense,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
              ),
              child: const Text(
                '저장',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
