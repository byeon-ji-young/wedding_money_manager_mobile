import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BudgetDialog extends StatefulWidget {
  final int? currentBudget;

  const BudgetDialog({super.key, this.currentBudget});

  @override
  State<BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<BudgetDialog> {
  late final TextEditingController controller;

  // 금액 입력 시 천 단위 쉼표 표시
  final amountFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
    final number = newValue.text.replaceAll(',', '');

    if (number.isEmpty) {
      return newValue.copyWith(text: '');
    }

    if (!RegExp(r'^\d+$').hasMatch(number)) {
      return oldValue;
    }

    final formatted = number.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  });

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(
      text: widget.currentBudget == null
          ? ''
          : widget.currentBudget!.toString().replaceAllMapped(
              RegExp(r'\B(?=(\d{3})+(?!\d))'),
              (match) => ',',
            ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('예산 설정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '결혼 준비에 사용할 전체 예산을 설정해주세요.',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [amountFormatter],
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colorScheme.secondary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            final text = controller.text.replaceAll(',', '').trim();
            final value = int.tryParse(text);

            if (value == null || value <= 0) {
              return;
            }

            Navigator.pop(context, value);
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}
