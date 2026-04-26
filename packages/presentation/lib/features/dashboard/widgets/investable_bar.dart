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
    final symbol     = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf         = NumberFormat('#,##0', 'en_US');
    final investable = model.investableCash;
    final safety     = model.safetyCash;
    final total      = model.currentCash;

    final safetyRatio     = total > 0
        ? (safety / total).clamp(0.0, 1.0) : 0.0;
    final investableRatio = total > 0
        ? (investable / total).clamp(0.0, 1.0) : 0.0;

    final summary = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INVESTABLE', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.xxs),
              Text('$symbol ${nf.format(investable)}',
                  style: AppTextStyles.metric
                      .copyWith(color: SC.metricInvestable)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SAFETY FUND', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.xxs),
              Text('$symbol ${nf.format(safety)}',
                  style: AppTextStyles.metric
                      .copyWith(color: SC.metricSafetyFund)),
            ],
          ),
        ),
      ],
    );

    final details = LayoutBuilder(builder: (_, c) {
      final w           = c.maxWidth;
      final safetyW     = w * safetyRatio;
      final investableW = w * investableRatio;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(children: [
              Container(height: 6, width: w,
                  color: AppColors.surfaceHigh),
              Container(height: 6, width: safetyW,
                  decoration: const BoxDecoration(
                      gradient: AppColors.gradientGold)),
              Positioned(
                left: safetyW,
                child: Container(
                  height: 6, width: investableW,
                  decoration: const BoxDecoration(
                      gradient: AppColors.gradientBlue),
                ),
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(children: [
            _dot(AppColors.gold, 'SAFETY'),
            const SizedBox(width: AppSpacing.md),
            _dot(AppColors.blue, 'INVESTABLE'),
          ]),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'DEPLOYABLE CAPITAL — separate from survival buffer',
            style: AppTextStyles.caption,
          ),
        ],
      );
    });

    return NeoExpandableCard(
      title: 'INVESTABLE',
      accentColor: AppColors.blue,
      initiallyExpanded: false,
      summary: summary,
      details: details,
    );
  }

  Widget _dot(Color color, String label) {
    return Row(children: [
      Container(width: 6, height: 6,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: AppSpacing.xxs + 2),
      Text(label, style: AppTextStyles.caption),
    ]);
  }
}
