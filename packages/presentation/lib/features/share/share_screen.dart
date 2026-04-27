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
    setState(() => _sharing = true);
    try {
      final boundary = _repaintKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final dir  = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/awareness_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: 'I have ${model.runwayDays} days of financial runway — '
            '${model.badge.emoji} ${model.badge.title}. '
            'How long can you survive? awareness.app',
      ));
    } catch (e) {
      debugPrint('Share error: $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _shareText(ModelState model) async {
    await SharePlus.instance.share(ShareParams(
      text: 'I have ${model.runwayDays} days of financial runway — '
          '${model.badge.emoji} ${model.badge.title}. '
          'You outlast ${model.badge.percentile}% of people. '
          'awareness.app',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(modelProvider);

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg,
                  AppSpacing.lg, AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SHARE', style: AppTextStyles.title),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text('CLOSE',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary)),
                    ),
                  ),
                ],
              ),
            ),
            Text('This is what will be shared',
                style: AppTextStyles.caption),
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
                    label: _sharing ? 'PREPARING...' : 'SHARE IMAGE',
                    variant: NeoButtonVariant.primary,
                    fullWidth: true,
                    onPressed:
                        _sharing ? null : () => _shareImage(model),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  NeoButton(
                    label: 'SHARE AS TEXT',
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
    final badge = model.badge;
    final color = switch (model.survivalStatus) {
      SurvivalStatus.stable   => AppColors.neonGreen,
      SurvivalStatus.caution  => AppColors.gold,
      SurvivalStatus.critical => AppColors.hotPink,
    };

    final numLabel = model.runwayDays >= 9999
        ? '∞'
        : model.runwayMonths >= 24
            ? (model.runwayMonths / 12).toStringAsFixed(1)
            : '${model.runwayDays}';

    final unitLabel = model.runwayDays >= 9999
        ? ''
        : model.runwayMonths >= 24
            ? 'YEARS LEFT'
            : 'DAYS LEFT';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 300, height: 375,
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
        child: Stack(children: [
          // Radial glow top
          Positioned(
            top: -60, left: -60, right: -60,
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
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Row(children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withAlpha(15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.neonGreen.withAlpha(50)),
                    ),
                    child: Center(child: Text('◈',
                        style: TextStyle(
                            color: AppColors.neonGreen,
                            fontSize: 10))),
                  ),
                  const SizedBox(width: 6),
                  Text('AWARENESS',
                      style: TextStyle(
                          fontSize: 10, letterSpacing: 2,
                          color: AppColors.neonGreen,
                          fontWeight: FontWeight.w500)),
                ]),

                const Spacer(),

                // Hero number
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(numLabel,
                    style: const TextStyle(
                      fontSize: 88,
                      fontWeight: FontWeight.w700,
                      height: 0.9,
                      letterSpacing: -1,
                      fontFamily: 'Courier New',
                    ),
                  ).copyWith(color: color),
                ),
                const SizedBox(height: 6),
                Text(unitLabel,
                    style: TextStyle(
                        fontSize: 11, letterSpacing: 3,
                        color: color.withAlpha(150),
                        fontWeight: FontWeight.w500)),

                const SizedBox(height: 20),

                Container(height: 1,
                    color: Colors.white.withAlpha(15)),

                const SizedBox(height: 20),

                // Badge
                Row(children: [
                  Text(badge.emoji,
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(badge.title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFCDD5E0))),
                      Text(badge.description,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7F96))),
                    ],
                  )),
                ]),

                const SizedBox(height: 14),

                // Social proof + URL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withAlpha(15),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: color.withAlpha(50)),
                      ),
                      child: Text(
                        'Top ${100 - badge.percentile}% of people',
                        style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Text('awareness.app',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF2A3D5A),
                            letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

extension on Text {
  Text copyWith({Color? color}) {
    return Text(data ?? '',
        style: style?.copyWith(color: color) ??
            TextStyle(color: color));
  }
}
