import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? existing;
  final void Function(
    TransactionType type,
    double amount,
    DateTime date,
    String? note,
  ) onSubmit;

  const TransactionForm({
    super.key,
    this.existing,
    required this.onSubmit,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  late TransactionType _type;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _type       = widget.existing?.type ?? TransactionType.expense;
    _date       = widget.existing?.date ?? DateTime.now();
    _amountCtrl = TextEditingController(
      text: widget.existing?.amount.value.toStringAsFixed(0) ?? '',
    );
    _noteCtrl   = TextEditingController(text: widget.existing?.note ?? '');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(_date).toUpperCase();
    final monthStr = SurvivalMonth(_date).toString();

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.existing == null ? '> NEW LOG ENTRY' : '> MODIFY ENTRY',
            style: AppTextStyles.title,
          ),
          const TerminalDivider(),

          // Type selector
          Text('TYPE', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: TransactionType.values.map((t) {
              final active = t == _type;
              return GestureDetector(
                onTap: () => setState(() => _type = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: active
                          ? AppColors.primaryGreen
                          : AppColors.dimGreen,
                    ),
                    color: active
                        ? AppColors.primaryGreen.withAlpha(20)
                        : AppColors.background,
                  ),
                  child: Text(
                    t.label,
                    style: AppTextStyles.small.copyWith(
                      color: active
                          ? AppColors.primaryGreen
                          : AppColors.dimGreen,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Full date picker
          Text('DATE', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.xs),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.dimGreen),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateStr, style: AppTextStyles.value),
                  Text(
                    'CALC: $monthStr',
                    style: AppTextStyles.small,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Amount
          TerminalInput(
            label: 'AMOUNT',
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            hint: '50000',
            maxLength: 13,
            inputFormatters: [AppInputFormatters.amount],
          ),
          const SizedBox(height: AppSpacing.md),

          // Note
          TerminalInput(
            label: 'NOTE (OPTIONAL)',
            controller: _noteCtrl,
            hint: 'rent + utilities',
            maxLength: 500,
            inputFormatters: [AppInputFormatters.text],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Buttons
          Row(
            children: [
              Expanded(
                child: TerminalButton(
                  label: 'CONFIRM',
                  onPressed: _submit,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TerminalButton(
                  label: 'ABORT',
                  isDestructive: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryGreen,
            surface: AppColors.background,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;
    widget.onSubmit(
      _type,
      amount,
      _date,
      _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    Navigator.of(context).pop();
  }
}
