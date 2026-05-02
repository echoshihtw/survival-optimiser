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
    final identity = copy.identityLabel(model.badge);
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
          text: copy.shareImageText(model.runwayDays, identity),
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
    final identity = copy.identityLabel(model.badge);
    await SharePlus.instance.share(
      ShareParams(
        text: copy.shareTextMessage(
          model.runwayDays,
          identity,
          model.badge.percentile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(modelProvider);
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
                  child: _ShareCard(model: model),
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
  const _ShareCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final copy = context.l10n.runwayShare;
    final badge = model.badge;
    final badgeTitle = copy.badgeTitle(badge);
    final emotionalLine = copy.emotionalLine(model.runwayDays);
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

                  Row(
                    children: [
                      Text(badge.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              badgeTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFCDD5E0),
                              ),
                            ),
                            Text(
                              emotionalLine,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7F96),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    copy.youOutlastPeople(badge.percentile),
                    style: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        copy.canYouBeatThis,
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

  String get canYouBeatThis => switch (_lang) {
    'es' => '¿Puedes superar esto?',
    'fr' => 'Pouvez-vous faire mieux ?',
    'it' => 'Riesci a batterlo?',
    'ja' => 'これを超えられますか？',
    'zh' => _isTraditionalChinese ? '你能超過嗎？' : '你能超过吗？',
    _ => 'Can you beat this?',
  };

  String youOutlastPeople(int percentile) => switch (_lang) {
    'es' => 'Sobrevives más que el $percentile% de las personas',
    'fr' => 'Vous tenez plus longtemps que $percentile% des gens',
    'it' => 'Resisti più del $percentile% delle persone',
    'ja' => 'あなたは$percentile%の人より長く持ちます',
    'zh' =>
      _isTraditionalChinese
          ? '你比 $percentile% 的人撐得更久'
          : '你比 $percentile% 的人撑得更久',
    _ => 'You outlast $percentile% of people',
  };

  String shareImageText(int days, String identity) => switch (_lang) {
    'es' =>
      'Si mi ingreso se detuviera hoy, sobrevivo $days días. $identity. ¿Puedes superar esto? RUNWAY',
    'fr' =>
      "Si mes revenus s'arrêtaient aujourd'hui, je tiens $days jours. $identity. Pouvez-vous faire mieux ? RUNWAY",
    'it' =>
      'Se il mio reddito si fermasse oggi, resisto $days giorni. $identity. Riesci a batterlo? RUNWAY',
    'ja' => '今日収入が止まったら、私は$days日生きられます。$identity。これを超えられますか？ RUNWAY',
    'zh' =>
      _isTraditionalChinese
          ? '如果我的收入今天停止，我能撐 $days 天。$identity。你能超過嗎？RUNWAY'
          : '如果我的收入今天停止，我能撑 $days 天。$identity。你能超过吗？RUNWAY',
    _ =>
      'If my income stopped today, I survive $days days. $identity. Can you beat this? RUNWAY',
  };

  String shareTextMessage(int days, String identity, int percentile) =>
      '${shareImageText(days, identity)} ${youOutlastPeople(percentile)}.';

  String get emotionExposed => switch (_lang) {
    'es' => 'Estás expuesto',
    'fr' => 'Vous êtes exposé',
    'it' => 'Sei esposto',
    'ja' => 'かなり危険です',
    'zh' => _isTraditionalChinese ? '你暴露在風險中' : '你暴露在风险中',
    _ => "You're exposed",
  };

  String get emotionCloser => switch (_lang) {
    'es' => 'Estás más cerca de lo que parece',
    'fr' => "C'est plus proche qu'il n'y paraît",
    'it' => 'È più vicino di quanto sembri',
    'ja' => '思ったより近いです',
    'zh' => '比你感觉的更近',
    _ => "You're closer than it feels",
  };

  String get emotionBreathingRoom => switch (_lang) {
    'es' => 'Tienes algo de margen',
    'fr' => "Vous avez un peu d'air",
    'it' => "Hai un po' di respiro",
    'ja' => '少し余裕があります',
    'zh' => _isTraditionalChinese ? '你還有一點喘息空間' : '你还有一点喘息空间',
    _ => 'You have some breathing room',
  };

  String get emotionSaferMost => switch (_lang) {
    'es' => 'Estás más seguro que la mayoría',
    'fr' => 'Vous êtes plus en sécurité que la plupart',
    'it' => 'Sei più al sicuro della maggior parte',
    'ja' => '多くの人より安全です',
    'zh' => _isTraditionalChinese ? '你比大多數人更安全' : '你比大多数人更安全',
    _ => "You're safer than most",
  };

  String get emotionAheadMost => switch (_lang) {
    'es' => 'Vas por delante de la mayoría',
    'fr' => 'Vous êtes devant la plupart des gens',
    'it' => 'Sei avanti rispetto alla maggior parte',
    'ja' => '多くの人より先にいます',
    'zh' => _isTraditionalChinese ? '你領先大多數人' : '你领先大多数人',
    _ => "You're ahead of most people",
  };

  String get badgeSurvivalMode => switch (_lang) {
    'es' => 'Modo supervivencia',
    'fr' => 'Mode survie',
    'it' => 'Modalità sopravvivenza',
    'ja' => 'サバイバルモード',
    'zh' => '生存模式',
    _ => 'Survival Mode',
  };

  String get badgeFinancialRookie => switch (_lang) {
    'es' => 'Novato financiero',
    'fr' => 'Débutant financier',
    'it' => 'Principiante finanziario',
    'ja' => '金融ルーキー',
    'zh' => _isTraditionalChinese ? '財務新手' : '财务新手',
    _ => 'Financial Rookie',
  };

  String get badgeGettingBy => switch (_lang) {
    'es' => 'Saliendo adelante',
    'fr' => 'Vous tenez le coup',
    'it' => 'Te la cavi',
    'ja' => 'なんとか持ちこたえ中',
    'zh' => _isTraditionalChinese ? '勉強撐住' : '勉强撑住',
    _ => 'Getting By',
  };

  String get badgeFinanciallyStable => switch (_lang) {
    'es' => 'Financieramente estable',
    'fr' => 'Financièrement stable',
    'it' => 'Finanziariamente stabile',
    'ja' => '経済的に安定',
    'zh' => _isTraditionalChinese ? '財務穩定' : '财务稳定',
    _ => 'Financially Stable',
  };

  String get badgeFinancialFortress => switch (_lang) {
    'es' => 'Fortaleza financiera',
    'fr' => 'Forteresse financière',
    'it' => 'Fortezza finanziaria',
    'ja' => '金融要塞',
    'zh' => _isTraditionalChinese ? '財務堡壘' : '财务堡垒',
    _ => 'Financial Fortress',
  };

  String get badgeEscapeVelocity => switch (_lang) {
    'es' => 'Velocidad de escape',
    'fr' => "Vitesse d'évasion",
    'it' => 'Velocità di fuga',
    'ja' => '脱出速度',
    'zh' => '逃逸速度',
    _ => 'Escape Velocity',
  };

  String identityLabel(IdentityBadge badge) =>
      '${badgeTitle(badge)} ${badge.emoji}';

  String emotionalLine(int days) {
    if (days < 30) return emotionExposed;
    if (days < 90) return emotionCloser;
    if (days < 180) return emotionBreathingRoom;
    if (days < 365) return emotionSaferMost;
    return emotionAheadMost;
  }

  String badgeTitle(IdentityBadge badge) {
    return switch (badge) {
      IdentityBadge.survivalMode => badgeSurvivalMode,
      IdentityBadge.financialRookie => badgeFinancialRookie,
      IdentityBadge.gettingBy => badgeGettingBy,
      IdentityBadge.financiallyStable => badgeFinanciallyStable,
      IdentityBadge.financialFortress => badgeFinancialFortress,
      IdentityBadge.escapeVelocity => badgeEscapeVelocity,
    };
  }
}
