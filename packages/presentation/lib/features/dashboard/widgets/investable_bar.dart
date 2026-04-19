import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:application/application.dart';
import 'package:intl/intl.dart';

class InvestableBar extends ConsumerWidget {
  final ModelState model;
  const InvestableBar({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n      = context.l10n;
    final currAsync = ref.watch(currencyProvider);
    final symbol    = currAsync.value?.symbol ?? '¥';

    final ratio  = model.surplus > 0
        ? (model.investableCash / model.surplus).clamp(0.0, 1.0)
        : 0.0;
    final amount = '$symbol ${NumberFormat('#,##0', 'en_US')
        .format(model.investableCash)}';
    final color  = model.investableCash > 0
        ? AppColors.safe
        : AppColors.dimGreen;

    return TerminalPanel(
      title: l10n.investable,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(amount,
              style: AppTextStyles.metric.copyWith(color: color)),
          const SizedBox(height: AppSpacing.xs),
          LayoutBuilder(
            builder: (_, constraints) {
              final total  = constraints.maxWidth;
              final filled = total * ratio;
              return Stack(
                children: [
                  Container(height: 8, width: total,
                      color: AppColors.panelBorder),
                  Container(height: 8, width: filled, color: color),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
