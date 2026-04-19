import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'dart:math';

class LoanWizard extends StatefulWidget {
  final void Function(
    double loanAmount,
    double monthlyPayment,
    DateTime date,
    String? note,
  ) onSubmit;

  const LoanWizard({super.key, required this.onSubmit});

  @override
  State<LoanWizard> createState() => _LoanWizardState();
}

class _LoanWizardState extends State<LoanWizard>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  final _amountCtrl  = TextEditingController();
  final _nameCtrl    = TextEditingController();
  final _rateCtrl    = TextEditingController();
  final _monthsCtrl  = TextEditingController();
  final _paymentCtrl = TextEditingController();
  final _noteCtrl    = TextEditingController();

  DateTime _date        = DateTime.now();
  bool _overridePayment = false;
  double? _computedPayment;
  String _source        = 'BANK';

  static const _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _rateCtrl.dispose();
    _monthsCtrl.dispose();
    _paymentCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < _totalSteps - 1) {
      _slideCtrl.reset();
      setState(() => _step++);
      _slideCtrl.forward();
    }
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }

  void _compute() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    final months = int.tryParse(_monthsCtrl.text.trim());
    final rate   = double.tryParse(_rateCtrl.text.trim());

    if (amount == null || months == null || months == 0) {
      setState(() => _computedPayment = null);
      return;
    }

    double payment;
    if (rate == null || rate == 0) {
      payment = amount / months;
    } else {
      final mr = rate / 100 / 12;
      payment  = amount * (mr * pow(1 + mr, months)) /
          (pow(1 + mr, months) - 1);
    }

    setState(() {
      _computedPayment = payment;
      if (!_overridePayment) _paymentCtrl.text = payment.toStringAsFixed(0);
    });
  }

  Future<void> _pickDate(AppLocalizations l10n) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.gold,
            surface: AppColors.background,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  bool get _step0Valid =>
      _nameCtrl.text.trim().isNotEmpty &&
      double.tryParse(_amountCtrl.text.trim()) != null;

  bool get _step1Valid =>
      int.tryParse(_monthsCtrl.text.trim()) != null;

  bool get _step2Valid =>
      double.tryParse(_paymentCtrl.text.trim()) != null;

  bool get _currentStepValid => switch (_step) {
    0 => _step0Valid,
    1 => _step1Valid,
    _ => _step2Valid,
  };

  void _submit() {
    final amount  = double.tryParse(_amountCtrl.text.trim());
    final payment = double.tryParse(_paymentCtrl.text.trim());
    if (amount == null || payment == null) return;
    final note = '$_source — ${_nameCtrl.text.trim()}'
        '${_noteCtrl.text.trim().isNotEmpty ? " | ${_noteCtrl.text.trim()}" : ""}';
    widget.onSubmit(amount, payment, _date, note);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('⚡ ${l10n.loanWizardTitle}',
                  style: AppTextStyles.title
                      .copyWith(color: AppColors.gold)),
              Text('${_step + 1} / $_totalSteps',
                  style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(_totalSteps, (i) => Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.only(
                    right: i < _totalSteps - 1 ? AppSpacing.xs : 0),
                color: i <= _step ? AppColors.gold : AppColors.panelBorder,
              ),
            )),
          ),
          const SizedBox(height: AppSpacing.lg),
          SlideTransition(
            position: _slideAnim,
            child: _buildStep(l10n),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [
            if (_step > 0) ...[
              TerminalButton(
                label: '← ${l10n.back}',
                color: AppColors.dimGreen,
                onPressed: _prevStep,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: _step < _totalSteps - 1
                  ? TerminalButton(
                      label: '${l10n.next} →',
                      fullWidth: true,
                      color: AppColors.gold,
                      onPressed: _currentStepValid ? _nextStep : null,
                    )
                  : TerminalButton(
                      label: l10n.confirm,
                      fullWidth: true,
                      color: AppColors.gold,
                      onPressed: _step2Valid ? _submit : null,
                    ),
            ),
          ]),
          const SizedBox(height: AppSpacing.sm),
          TerminalButton(
            label: l10n.abort,
            fullWidth: true,
            isDestructive: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(AppLocalizations l10n) => switch (_step) {
    0 => _buildStep0(l10n),
    1 => _buildStep1(l10n),
    _ => _buildStep2(l10n),
  };

  Widget _buildStep0(AppLocalizations l10n) {
    final sources = ['BANK', 'FRIEND', 'FAMILY', 'OTHER'];
    final months  = ['JAN','FEB','MAR','APR','MAY','JUN',
                     'JUL','AUG','SEP','OCT','NOV','DEC'];
    final dateStr = '${_date.day.toString().padLeft(2, '0')} '
        '${months[_date.month - 1]} ${_date.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.whoAndHowMuch, style: AppTextStyles.label
            .copyWith(color: AppColors.gold, letterSpacing: 2)),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.source, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: sources.map((s) {
            final active = s == _source;
            return GestureDetector(
              onTap: () => setState(() => _source = s),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: active ? AppColors.gold : AppColors.dimGreen,
                    width: active ? 1.5 : 1,
                  ),
                  color: active
                      ? AppColors.gold.withAlpha(20)
                      : AppColors.background,
                ),
                child: Text(s,
                    style: AppTextStyles.value.copyWith(
                        color: active ? AppColors.gold : AppColors.dimGreen)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        TerminalInput(
          label: l10n.nameLender,
          controller: _nameCtrl,
          hint: _source == 'BANK' ? 'HSBC' : 'John',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        TerminalInput(
          label: l10n.loanAmount,
          controller: _amountCtrl,
          keyboardType: TextInputType.number,
          hint: '500000',
          onChanged: (_) { setState(() {}); _compute(); },
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.date, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: () => _pickDate(l10n),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
            decoration:
                BoxDecoration(border: Border.all(color: AppColors.dimGreen)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr, style: AppTextStyles.value),
                Text('[ ${l10n.change} ]', style: AppTextStyles.small),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.loanTerms, style: AppTextStyles.label
            .copyWith(color: AppColors.gold, letterSpacing: 2)),
        const SizedBox(height: AppSpacing.md),
        TerminalInput(
          label: l10n.annualRate,
          controller: _rateCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          hint: '0',
          onChanged: (_) => _compute(),
        ),
        const SizedBox(height: AppSpacing.md),
        TerminalInput(
          label: l10n.repaymentMonths,
          controller: _monthsCtrl,
          keyboardType: TextInputType.number,
          hint: '24',
          onChanged: (_) { setState(() {}); _compute(); },
        ),
        if (_computedPayment != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gold),
              color: AppColors.gold.withAlpha(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.computedInstallment,
                        style: AppTextStyles.label),
                    Text('/MO', style: AppTextStyles.small),
                  ],
                ),
                Text(_computedPayment!.toStringAsFixed(0),
                    style: AppTextStyles.metric
                        .copyWith(color: AppColors.gold)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep2(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.confirmPayment, style: AppTextStyles.label
            .copyWith(color: AppColors.gold, letterSpacing: 2)),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.panelBorder)),
          child: Column(
            children: [
              _summaryRow(l10n.source, _source),
              _summaryRow(l10n.lender, _nameCtrl.text.toUpperCase()),
              _summaryRow(l10n.loanAmount, _amountCtrl.text),
              _summaryRow(l10n.repaymentMonths, _monthsCtrl.text),
              if (_rateCtrl.text.isNotEmpty && _rateCtrl.text != '0')
                _summaryRow(l10n.rate, '${_rateCtrl.text}%'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () => setState(() {
            _overridePayment = !_overridePayment;
            if (!_overridePayment && _computedPayment != null) {
              _paymentCtrl.text = _computedPayment!.toStringAsFixed(0);
            }
          }),
          child: Row(children: [
            Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.dimGreen),
                color: _overridePayment
                    ? AppColors.gold.withAlpha(60)
                    : AppColors.background,
              ),
              child: _overridePayment
                  ? const Icon(Icons.check, size: 10, color: AppColors.gold)
                  : null,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(l10n.overrideInstallment, style: AppTextStyles.small),
          ]),
        ),
        const SizedBox(height: AppSpacing.md),
        TerminalInput(
          label: l10n.monthlyInstallment,
          controller: _paymentCtrl,
          keyboardType: TextInputType.number,
          hint: _computedPayment?.toStringAsFixed(0) ?? '0',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        TerminalInput(
          label: l10n.noteOptional,
          controller: _noteCtrl,
          hint: 'home renovation',
          onChanged: (_) {},
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(value,
              style: AppTextStyles.value.copyWith(color: AppColors.gold)),
        ],
      ),
    );
  }
}
