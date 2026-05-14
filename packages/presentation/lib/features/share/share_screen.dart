import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final _repaintKey = GlobalKey();
  bool _sharing = false;

  Future<void> _shareImage(ModelState model) async {
    final copy = context.l10n.runwayShare;
    final goal = ref.read(runwayGoalProvider).value;
    setState(() => _sharing = true);
    try {
      final boundary =
          _repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/runway_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: copy.shareImageText(model.runwayDays, goal, model.runwayMonths),
        ),
      );
    } catch (e) {
      debugPrint('Share error: $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _shareText(ModelState model) async {
    final copy = context.l10n.runwayShare;
    final goal = ref.read(runwayGoalProvider).value;
    await SharePlus.instance.share(
      ShareParams(
        text: copy.shareTextMessage(model.runwayDays, goal, model.runwayMonths),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(modelProvider);
    final goal = ref.watch(runwayGoalProvider).value;
    final copy = context.l10n.runwayShare;

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(copy.shareSafe, style: AppTextStyles.title),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        context.l10n.close,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(copy.shareSafeHint, style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.lg),

            Expanded(
              child: Center(
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: _ShareCard(model: model, goal: goal),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  NeoButton(
                    label: _sharing ? copy.preparing : copy.shareImage,
                    variant: NeoButtonVariant.primary,
                    fullWidth: true,
                    onPressed: _sharing ? null : () => _shareImage(model),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  NeoButton(
                    label: copy.shareAsText,
                    variant: NeoButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () => _shareText(model),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  final ModelState model;
  final RunwayGoal? goal;

  const _ShareCard({required this.model, required this.goal});

  @override
  Widget build(BuildContext context) {
    final copy = context.l10n.runwayShare;
    final color = switch (model.survivalStatus) {
      SurvivalStatus.stable => AppColors.neonGreen,
      SurvivalStatus.caution => AppColors.gold,
      SurvivalStatus.critical => AppColors.hotPink,
    };

    final numLabel = model.runwayDays >= 9999 ? '∞' : '${model.runwayDays}';
    final unitLabel = model.runwayDays >= 9999 ? '' : copy.daysUpper;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 320,
        height: 560,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(const Color(0xFF040D1A), color, 0.10)!,
              const Color(0xFF020810),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Radial glow top
            Positioned(
              top: -60,
              left: -60,
              right: -60,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [color.withAlpha(30), Colors.transparent],
                    radius: 0.65,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen.withAlpha(15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.neonGreen.withAlpha(50),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '◈',
                            style: TextStyle(
                              color: AppColors.neonGreen,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        copy.runwayBrand,
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 2,
                          color: AppColors.neonGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Text(
                    copy.ifIncomeStoppedToday,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFFCDD5E0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Hero number
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      numLabel,
                      style: TextStyle(
                        fontSize: 108,
                        fontWeight: FontWeight.w700,
                        height: 0.9,
                        letterSpacing: -1,
                        fontFamily: 'Courier New',
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    unitLabel,
                    style: TextStyle(
                      fontSize: 22,
                      letterSpacing: 3,
                      color: color.withAlpha(150),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Courier New',
                    ),
                  ),

                  const SizedBox(height: 28),

                  if (goal != null)
                    _GoalShareBlock(model: model, goal: goal!, color: color),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        copy.privateByDefault,
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7F96),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        copy.runwayBrand,
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF2A3D5A),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalShareBlock extends StatelessWidget {
  const _GoalShareBlock({
    required this.model,
    required this.goal,
    required this.color,
  });

  final ModelState model;
  final RunwayGoal goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final copy = context.l10n.runwayShare;
    final percent = calculateRunwayGoalProgressPercent(
      runwayMonths: model.runwayMonths.toDouble(),
      targetMonths: goal.targetMonths,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF071120),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal.name,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.6,
              color: Color(0xFF6B7F96),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            copy.goalProgress(percent, goal.targetMonths),
            style: TextStyle(
              fontSize: 15,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            copy.basedOnGoal,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7F96)),
          ),
        ],
      ),
    );
  }
}

extension _RunwayShareCopyAccess on AppLocalizations {
  _RunwayShareCopy get runwayShare => _RunwayShareCopy(localeName);
}

class _RunwayShareCopy {
  final String localeName;

  const _RunwayShareCopy(this.localeName);

  String get _lang => localeName.split('_').first;

  bool get _isTraditionalChinese =>
      localeName == 'zh_TW' || localeName.toLowerCase().contains('hant');

  String get runwayBrand => 'RUNWAY';

  String get ifIncomeStoppedToday => switch (_lang) {
    'es' => 'Si tu ingreso se detuviera hoy',
    'fr' => "Si vos revenus s'arrêtaient aujourd'hui",
    'it' => 'Se il tuo reddito si fermasse oggi',
    'ja' => '今日、収入が止まったら',
    'zh' => '如果你的收入今天停止',
    _ => 'If your income stopped today',
  };

  String get daysUpper => switch (_lang) {
    'es' => 'DÍAS',
    'fr' => 'JOURS',
    'it' => 'GIORNI',
    'ja' => '日',
    'zh' => '天',
    _ => 'DAYS',
  };

  String get shareSafe => switch (_lang) {
    'es' => 'COMPARTIR SEGURO',
    'fr' => 'PARTAGE SÛR',
    'it' => 'CONDIVISIONE SICURA',
    'ja' => '安全に共有',
    'zh' => '安全分享',
    _ => 'SHARE SAFE',
  };

  String get shareSafeHint => switch (_lang) {
    'es' => 'Sin ahorros. Sin gastos. Solo tu autonomía.',
    'fr' => "Pas d'épargne. Pas de dépenses. Juste votre runway.",
    'it' => 'Niente risparmi. Niente spese. Solo il tuo runway.',
    'ja' => '貯金額も支出も出しません。ランウェイだけ。',
    'zh' =>
      _isTraditionalChinese
          ? '不顯示存款。不顯示支出。只顯示你的生存跑道。'
          : '不显示存款。不显示支出。只显示你的生存跑道。',
    _ => 'No savings. No expenses. Just your runway.',
  };

  String get preparing => switch (_lang) {
    'es' => 'PREPARANDO...',
    'fr' => 'PRÉPARATION...',
    'it' => 'PREPARAZIONE...',
    'ja' => '準備中...',
    'zh' => _isTraditionalChinese ? '準備中...' : '准备中...',
    _ => 'PREPARING...',
  };

  String get shareImage => switch (_lang) {
    'es' => 'COMPARTIR IMAGEN',
    'fr' => "PARTAGER L'IMAGE",
    'it' => 'CONDIVIDI IMMAGINE',
    'ja' => '画像を共有',
    'zh' => '分享图片',
    _ => 'SHARE IMAGE',
  };

  String get shareAsText => switch (_lang) {
    'es' => 'COMPARTIR TEXTO',
    'fr' => 'PARTAGER EN TEXTE',
    'it' => 'CONDIVIDI TESTO',
    'ja' => 'テキストで共有',
    'zh' => _isTraditionalChinese ? '以文字分享' : '以文字分享',
    _ => 'SHARE AS TEXT',
  };

  String goalProgress(int percent, int months) => switch (_lang) {
    'es' => '$percent% de un objetivo de $months meses',
    'fr' => '$percent% d’un objectif de $months mois',
    'it' => '$percent% di un obiettivo di $months mesi',
    'ja' => '$monthsか月目標の$percent%',
    'zh' =>
      _isTraditionalChinese
          ? '達成 $months 個月目標的 $percent%'
          : '达成 $months 个月目标的 $percent%',
    _ => '$percent% of a $months-month target',
  };

  String get basedOnGoal => switch (_lang) {
    'es' => 'Basado solo en efectivo disponible y gasto mensual.',
    'fr' => 'Basé uniquement sur les liquidités et le coût mensuel.',
    'it' => 'Basato solo su cassa disponibile e spesa mensile.',
    'ja' => '手元資金と月間支出だけに基づきます。',
    'zh' => _isTraditionalChinese ? '僅根據可用現金與每月支出計算。' : '仅根据可用现金与每月支出计算。',
    _ => 'Based only on available cash and monthly burn.',
  };

  String get privateByDefault => switch (_lang) {
    'es' => 'Privado por defecto',
    'fr' => 'Privé par défaut',
    'it' => 'Privato per impostazione predefinita',
    'ja' => '標準でプライベート',
    'zh' => _isTraditionalChinese ? '預設保密' : '默认保密',
    _ => 'Private by default',
  };

  String shareImageText(int days, RunwayGoal? goal, int runwayMonths) {
    final base = switch (_lang) {
      'es' => 'Si mi ingreso se detuviera hoy, mi runway sería de $days días.',
      'fr' =>
        "Si mes revenus s'arrêtaient aujourd'hui, mon runway serait de $days jours.",
      'it' =>
        'Se il mio reddito si fermasse oggi, il mio runway sarebbe di $days giorni.',
      'ja' => '今日収入が止まった場合、ランウェイは$days日です。',
      'zh' =>
        _isTraditionalChinese
            ? '如果我的收入今天停止，我的跑道是 $days 天。'
            : '如果我的收入今天停止，我的跑道是 $days 天。',
      _ => 'If my income stopped today, my runway is $days days.',
    };
    if (goal == null) return '$base RUNWAY';

    final percent = calculateRunwayGoalProgressPercent(
      runwayMonths: runwayMonths.toDouble(),
      targetMonths: goal.targetMonths,
    );
    return '$base ${goal.name}: ${goalProgress(percent, goal.targetMonths)}. RUNWAY';
  }

  String shareTextMessage(int days, RunwayGoal? goal, int runwayMonths) =>
      shareImageText(days, goal, runwayMonths);
}
