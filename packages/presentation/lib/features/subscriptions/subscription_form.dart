import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

class SubscriptionForm extends StatefulWidget {
  final Subscription? existing;
  final void Function(
    String name,
    SubscriptionCategory category,
    double amount,
    BillingCycle cycle,
    DateTime startDate,
    String? note,
  ) onSubmit;

  const SubscriptionForm({
    super.key,
    this.existing,
    required this.onSubmit,
  });

  @override
  State<SubscriptionForm> createState() => _SubscriptionFormState();
}

class _SubscriptionFormState extends State<SubscriptionForm> {
  final _nameCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();

  late SubscriptionCategory _category;
  late BillingCycle          _cycle;
  late DateTime              _startDate;

  @override
  void initState() {
    super.initState();
    _category  = widget.existing?.category  ?? SubscriptionCategory.personal;
    _cycle     = widget.existing?.cycle     ?? BillingCycle.monthly;
    _startDate = widget.existing?.startDate ?? DateTime.now();
    _nameCtrl.text   = widget.existing?.name ?? '';
    _amountCtrl.text = widget.existing?.amount.toStringAsFixed(0) ?? '';
    _noteCtrl.text   = widget.existing?.note ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.safe,
            surface: AppColors.background,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _submit() {
    final name   = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (name.isEmpty || amount == null || amount <= 0) return;
    widget.onSubmit(
      name,
      _category,
      amount,
      _cycle,
      _startDate,
      _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n    = context.l10n;
    final dateStr = DateFormat('dd MMM yyyy').format(_startDate).toUpperCase();

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.only(
        left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing == null
                  ? l10n.addSubscription
                  : l10n.editSubscription,
              style: AppTextStyles.title.copyWith(color: AppColors.safe),
            ),
            const TerminalDivider(),

            // Category
            Text(l10n.subscriptionCategory, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Row(children: SubscriptionCategory.values.map((c) {
              final active = c == _category;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: Container(
                    margin: EdgeInsets.only(
                        right: c != SubscriptionCategory.values.last
                            ? AppSpacing.xs : 0),
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: active ? AppColors.safe : AppColors.dimGreen,
                        width: active ? 1.5 : 1,
                      ),
                      color: active
                          ? AppColors.safe.withAlpha(20)
                          : AppColors.background,
                    ),
                    child: Center(
                      child: Text(
                        c == SubscriptionCategory.personal
                            ? l10n.personal
                            : l10n.business,
                        style: AppTextStyles.small.copyWith(
                          color: active ? AppColors.safe : AppColors.dimGreen,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList()),
            const SizedBox(height: AppSpacing.md),

            // Name
            TerminalInput(
              label: l10n.subscriptionName,
              controller: _nameCtrl,
              hint: 'Netflix',
              onChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.md),

            // Amount
            TerminalInput(
              label: l10n.subscriptionAmount,
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              hint: '1990',
              onChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.md),

            // Billing cycle
            Text(l10n.subscriptionCycle, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: BillingCycle.values.map((c) {
                final active = c == _cycle;
                return GestureDetector(
                  onTap: () => setState(() => _cycle = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: active ? AppColors.safe : AppColors.dimGreen,
                        width: active ? 1.5 : 1,
                      ),
                      color: active
                          ? AppColors.safe.withAlpha(20)
                          : AppColors.background,
                    ),
                    child: Text(
                      _cycleLabel(c, l10n),
                      style: AppTextStyles.small.copyWith(
                        color: active ? AppColors.safe : AppColors.dimGreen,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Start date
            Text(l10n.date, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.dimGreen)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateStr, style: AppTextStyles.value),
                    Text('[ ${l10n.change} ]', style: AppTextStyles.small),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Note
            TerminalInput(
              label: l10n.noteOptional,
              controller: _noteCtrl,
              hint: 'streaming service',
              onChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.lg),

            Row(children: [
              Expanded(
                child: TerminalButton(
                  label: l10n.confirm,
                  fullWidth: true,
                  color: AppColors.safe,
                  onPressed: _submit,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TerminalButton(
                  label: l10n.abort,
                  fullWidth: true,
                  isDestructive: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  String _cycleLabel(BillingCycle c, AppLocalizations l10n) => switch (c) {
    BillingCycle.weekly    => l10n.weekly,
    BillingCycle.monthly   => l10n.monthly,
    BillingCycle.quarterly => l10n.quarterly,
    BillingCycle.yearly    => l10n.yearly,
  };
}
