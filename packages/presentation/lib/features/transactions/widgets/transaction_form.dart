import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? existing;
  final TransactionType? preselectedType;
  final List<Loan> loans;
  final void Function(
    TransactionType type,
    double amount,
    DateTime date,
    String? note,
    ExpenseCategory? category,
    String? loanId,
  )
  onSubmit;

  const TransactionForm({
    super.key,
    this.existing,
    this.preselectedType,
    this.loans = const [],
    required this.onSubmit,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  late TransactionType _type;
  late DateTime _date;
  String? _categoryGroup;
  ExpenseCategory? _category;
  String? _selectedLoanId;

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
    _type =
        widget.existing?.type ??
        widget.preselectedType ??
        TransactionType.expense;
    _date = widget.existing?.date ?? DateTime.now();
    _amountCtrl.text = widget.existing?.amount.value.toStringAsFixed(0) ?? '';
    _noteCtrl.text = widget.existing?.note ?? '';
    _selectedLoanId = widget.existing?.loanId;
    if (_type == TransactionType.repayment && _selectedLoanId == null) {
      _selectedLoanId = _defaultLoanId();
    }
    final existingCategory = widget.existing?.category;
    if (existingCategory != null) {
      _category = existingCategory;
      _categoryGroup = existingCategory.group;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Color _typeColor(TransactionType t) => switch (t) {
    TransactionType.income => AppColors.green,
    TransactionType.openingBalance => AppColors.blue,
    TransactionType.loan => AppColors.blue,
    TransactionType.expense => AppColors.red,
    TransactionType.repayment => AppColors.gold,
    TransactionType.investment => AppColors.purple,
  };

  String _typeLabel(TransactionType t, AppLocalizations l10n) => switch (t) {
    TransactionType.expense => l10n.typeExpense,
    TransactionType.income => l10n.typeIncome,
    TransactionType.loan => l10n.typeLoan,
    TransactionType.investment => l10n.typeInvest,
    TransactionType.repayment => l10n.typeRepay,
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

  void _onGroupTap(String group) {
    setState(() {
      _categoryGroup = group;
      _category = ExpenseCategory.groupHasSubcategories(group)
          ? null
          : ExpenseCategory.subcategoriesFor(group).first;
    });
  }

  String? _defaultLoanId() {
    if (widget.loans.isEmpty) return null;
    final activeLoans = widget.loans.where((loan) => loan.isActive);
    return (activeLoans.isNotEmpty ? activeLoans : widget.loans).first.id;
  }

  void _onTypeTap(TransactionType type) {
    setState(() {
      _type = type;
      if (type != TransactionType.repayment) {
        _selectedLoanId = null;
      } else if (_selectedLoanId == null && widget.loans.isNotEmpty) {
        _selectedLoanId = _defaultLoanId();
      }
    });
  }

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;
    final loanId = _type == TransactionType.repayment ? _selectedLoanId : null;
    if (_type == TransactionType.repayment) {
      final validLoanIds = widget.loans.map((loan) => loan.id).toSet();
      if (loanId == null || !validLoanIds.contains(loanId)) return;
    }
    widget.onSubmit(
      _type,
      amount,
      _date,
      _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      _type == TransactionType.expense ? _category : null,
      loanId,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final dateStr = DateFormat(
      'dd MMM yyyy',
      locale,
    ).format(_date).toUpperCase();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              widget.existing == null
                  ? l10n.newLogEntry.toUpperCase()
                  : l10n.modifyEntry.toUpperCase(),
              style: AppTextStyles.title,
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(l10n.type, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _types.map((t) {
                final active = t == _type;
                final color = _typeColor(t);
                return GestureDetector(
                  onTap: () => _onTypeTap(t),
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

            if (_type == TransactionType.expense) ...[
              Text('CATEGORY', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: ExpenseCategory.groups.map((group) {
                  final active = _categoryGroup == group;
                  return GestureDetector(
                    onTap: () => _onGroupTap(group),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.blue.withAlpha(20)
                            : AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: active ? AppColors.blue : AppColors.cardBorder,
                          width: active ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        group,
                        style: AppTextStyles.caption.copyWith(
                          color: active
                              ? AppColors.blue
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_categoryGroup != null &&
                  ExpenseCategory.groupHasSubcategories(_categoryGroup!)) ...[
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: ExpenseCategory.subcategoriesFor(_categoryGroup!)
                      .map((cat) {
                        final active = _category == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _category = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs + 2,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.red.withAlpha(20)
                                  : AppColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: active
                                    ? AppColors.red
                                    : AppColors.cardBorder,
                                width: active ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              cat.label,
                              style: AppTextStyles.caption.copyWith(
                                color: active
                                    ? AppColors.red
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],

            if (_type == TransactionType.repayment) ...[
              Text('LOAN', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.xs),
              if (widget.loans.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    'Add a loan before recording a repayment.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: widget.loans.map((loan) {
                    final active = _selectedLoanId == loan.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedLoanId = loan.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs + 2,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.gold.withAlpha(20)
                              : AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: active
                                ? AppColors.gold
                                : AppColors.cardBorder,
                            width: active ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          loan.name.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: active
                                ? AppColors.gold
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: AppSpacing.lg),
            ],

            NeoInput(
              label: l10n.amount,
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              hint: '50,000',
            ),
            const SizedBox(height: AppSpacing.md),

            Text(l10n.date, style: AppTextStyles.label),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateStr, style: AppTextStyles.body),
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            NeoInput(
              label: l10n.noteOptional,
              controller: _noteCtrl,
              hint: 'groceries, rent...',
            ),
            const SizedBox(height: AppSpacing.lg),

            Row(
              children: [
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
