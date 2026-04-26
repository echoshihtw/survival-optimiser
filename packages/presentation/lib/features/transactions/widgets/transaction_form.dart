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
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();

  late TransactionType _type;
  late DateTime _date;

  static const _types = [
    TransactionType.expense,
    TransactionType.income,
    TransactionType.investment,
    TransactionType.repayment,
    TransactionType.openingBalance,
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.existing?.type ?? TransactionType.expense;
    _date = widget.existing?.date ?? DateTime.now();
    _amountCtrl.text =
        widget.existing?.amount.value.toStringAsFixed(0) ?? '';
    _noteCtrl.text = widget.existing?.note ?? '';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Color _typeColor(TransactionType t) => switch (t) {
    TransactionType.income         => AppColors.green,
    TransactionType.openingBalance => AppColors.blue,
    TransactionType.loan           => AppColors.blue,
    TransactionType.expense        => AppColors.red,
    TransactionType.repayment      => AppColors.gold,
    TransactionType.investment     => AppColors.purple,
  };

  String _typeLabel(TransactionType t, AppLocalizations l10n) =>
      switch (t) {
    TransactionType.expense        => l10n.typeExpense,
    TransactionType.income         => l10n.typeIncome,
    TransactionType.loan           => l10n.typeLoan,
    TransactionType.investment     => l10n.typeInvest,
    TransactionType.repayment      => l10n.typeRepay,
    TransactionType.openingBalance => l10n.typeOpening,
  };

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.green,
            surface: AppColors.surface,
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
      _type, amount, _date,
      _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n    = context.l10n;
    final dateStr = DateFormat('dd MMM yyyy')
        .format(_date).toUpperCase();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.cardRadius)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg, right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              widget.existing == null
                  ? l10n.newEntry.toUpperCase()
                  : 'EDIT ENTRY',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Type selector
            Text('TYPE', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _types.map((t) {
                final active = t == _type;
                final color  = _typeColor(t);
                return GestureDetector(
                  onTap: () => setState(() => _type = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? color.withAlpha(20)
                          : AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: active ? color : AppColors.cardBorder,
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      _typeLabel(t, l10n).toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: active ? color : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Amount
            NeoInput(
              label: 'AMOUNT',
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              hint: '50,000',
            ),
            const SizedBox(height: AppSpacing.md),

            // Date
            Text('DATE', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateStr, style: AppTextStyles.body),
                    const Icon(Icons.calendar_today_rounded,
                        color: AppColors.textSecondary, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Note
            NeoInput(
              label: 'NOTE (OPTIONAL)',
              controller: _noteCtrl,
              hint: 'groceries, rent...',
            ),
            const SizedBox(height: AppSpacing.lg),

            // Actions
            Row(children: [
              Expanded(
                child: NeoButton(
                  label: l10n.confirm,
                  variant: NeoButtonVariant.primary,
                  fullWidth: true,
                  onPressed: _submit,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: NeoButton(
                  label: l10n.abort,
                  variant: NeoButtonVariant.ghost,
                  fullWidth: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
