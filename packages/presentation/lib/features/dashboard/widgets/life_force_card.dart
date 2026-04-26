import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:application/application.dart';
import 'package:intl/intl.dart';

class LifeForceCard extends ConsumerWidget {
  final ModelState model;
  const LifeForceCard({super.key, required this.model});

  static const _studyPeriodMonths = 24;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf     = NumberFormat('#,##0', 'en_US');
    final status = model.survivalStatus;

    final color = switch (status) {
      SurvivalStatus.stable   => AppColors.green,
      SurvivalStatus.caution  => AppColors.gold,
      SurvivalStatus.critical => AppColors.red,
    };
    final statusLabel = switch (status) {
      SurvivalStatus.stable   => 'STABLE',
      SurvivalStatus.caution  => 'CAUTION',
      SurvivalStatus.critical => 'CRITICAL',
    };

    final charge = model.runwayMonths >= 9999
        ? 1.0
        : (model.runwayMonths / _studyPeriodMonths).clamp(0.0, 1.0);
    final chargePercent = (charge * 100).round();

    String fmtRunway(int m) {
      if (m >= 9999) return '∞';
      if (m >= 24)   return '${(m / 12).toStringAsFixed(1)}';
      return '$m';
    }
    String fmtRunwayUnit(int m) {
      if (m >= 9999) return '';
      if (m >= 24)   return 'YRS';
      return 'MO';
    }
    String fmtDate(DateTime? d) =>
        d == null ? '—'
            : DateFormat('MMM yyyy').format(d).toUpperCase();

    return LiquidGlassContainer(
      accentColor: color,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmtRunway(model.runwayMonths),
                style: AppTextStyles.heroLarge.copyWith(
                  color: color, fontSize: 72,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  ' ${fmtRunwayUnit(model.runwayMonths)}',
                  style: AppTextStyles.metric
                      .copyWith(color: color.withAlpha(180)),
                ),
              ),
            ],
          ),
          Text('RUNWAY',
              style: AppTextStyles.sectionTitle
                  .copyWith(letterSpacing: 3)),
          const SizedBox(height: AppSpacing.sm),
          PixelBadge(label: statusLabel, color: color),
          const SizedBox(height: AppSpacing.xl),
          PixelBar(
            value: charge, color: color,
            segments: 24, height: 6,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SURVIVAL CHARGE', style: AppTextStyles.caption),
              Text('$chargePercent%',
                  style: AppTextStyles.caption
                      .copyWith(color: color)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: Colors.white.withAlpha(15), height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(child: _stat('CASH',
                '$symbol ${nf.format(model.currentCash)}',
                AppColors.green)),
            Expanded(child: _stat('RUN OUT',
                fmtDate(model.runOutDate),
                AppColors.textSecondary)),
            Expanded(child: _stat('TOTAL/MO',
                '-$symbol ${nf.format(model.totalMonthlyOutflow)}',
                AppColors.red)),
          ]),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xxs),
        Text(value,
            style: AppTextStyles.caption
                .copyWith(color: color, fontSize: 12),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

// ── Liquid Glass Card ─────────────────────────────────────────
class _LiquidGlassCard extends StatefulWidget {
  final Widget child;
  final Color accentColor;

  const _LiquidGlassCard({
    required this.child,
    required this.accentColor,
  });

  @override
  State<_LiquidGlassCard> createState() => _LiquidGlassCardState();
}

class _LiquidGlassCardState extends State<_LiquidGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Stack(
        children: [
          // Layer 1 — backdrop blur (refraction base)
          ClipRRect(
            borderRadius:
                BorderRadius.circular(AppSpacing.cardRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      AppSpacing.cardRadius),
                  color: Colors.transparent,
                ),
              ),
            ),
          ),

          // Layer 2 — glass body with volume
          CustomPaint(
            painter: _GlassBodyPainter(
              t: _ctrl.value,
              accentColor: widget.accentColor,
              radius: AppSpacing.cardRadius,
            ),
          ),

          // Layer 3 — content
          ClipRRect(
            borderRadius:
                BorderRadius.circular(AppSpacing.cardRadius),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    AppSpacing.cardRadius),
                color: Colors.transparent,
              ),
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: child,
            ),
          ),

          // Layer 4 — specular rim on top (painted last)
          CustomPaint(
            painter: _GlassRimPainter(
              t: _ctrl.value,
              radius: AppSpacing.cardRadius,
            ),
          ),
        ],
      ),
      child: widget.child,
    );
  }
}

// ── Glass body — fills the card with glass volume ─────────────
class _GlassBodyPainter extends CustomPainter {
  final double t;
  final Color accentColor;
  final double radius;

  _GlassBodyPainter({
    required this.t,
    required this.accentColor,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
        rect, Radius.circular(radius));

    // Base glass fill — semi-transparent dark
    canvas.drawRRect(rrect, Paint()
      ..color = const Color(0xFF111318).withAlpha(200));

    // Inner light scatter — top half brighter (light enters top)
    canvas.drawRRect(rrect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.4, 1.0],
        colors: [
          Colors.white.withAlpha(18),
          Colors.white.withAlpha(5),
          Colors.white.withAlpha(0),
        ],
      ).createShader(rect));

    // Accent tint — very subtle color from status
    canvas.drawRRect(rrect, Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.5),
        radius: 1.2,
        colors: [
          accentColor.withAlpha(12),
          accentColor.withAlpha(0),
        ],
      ).createShader(rect));

    // Inner shadow — depth at bottom
    canvas.drawRRect(rrect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        stops: const [0.0, 0.3],
        colors: [
          Colors.black.withAlpha(40),
          Colors.black.withAlpha(0),
        ],
      ).createShader(rect));

    // Animated shimmer — slow moving light inside glass
    final shimmerX = 0.5 + cos(t * 2 * pi) * 0.3;
    final shimmerY = 0.3 + sin(t * pi) * 0.2;
    canvas.drawRRect(rrect, Paint()
      ..shader = RadialGradient(
        center: Alignment(shimmerX * 2 - 1, shimmerY * 2 - 1),
        radius: 0.6,
        colors: [
          Colors.white.withAlpha(
              (12 * (0.5 + 0.5 * sin(t * 2 * pi))).round()),
          Colors.white.withAlpha(0),
        ],
      ).createShader(rect));
  }

  @override
  bool shouldRepaint(_GlassBodyPainter old) => old.t != t;
}

// ── Glass rim — the edge specular ring ────────────────────────
class _GlassRimPainter extends CustomPainter {
  final double t;
  final double radius;

  _GlassRimPainter({required this.t, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
        rect, Radius.circular(radius));

    // Outer border — gradient sweep simulating glass thickness
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = SweepGradient(
          center: Alignment.topLeft,
          startAngle: -pi * 0.25,  // 45° — light from upper left
          endAngle: -pi * 0.25 + pi * 2,
          stops: const [0.0, 0.08, 0.25, 0.5, 0.75, 0.92, 1.0],
          colors: [
            Colors.white.withAlpha(180), // top-left — peak specular
            Colors.white.withAlpha(80),  // upper edge bright
            Colors.white.withAlpha(20),  // top-right fade
            Colors.white.withAlpha(8),   // bottom-right dark
            Colors.white.withAlpha(12),  // bottom-left slight bounce
            Colors.white.withAlpha(60),  // left edge — secondary
            Colors.white.withAlpha(180), // back to peak
          ],
        ).createShader(rect),
    );

    // Inner rim — 1px inset, softer
    final innerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      Radius.circular(radius - 1),
    );
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..shader = SweepGradient(
          center: Alignment.topLeft,
          startAngle: -pi * 0.25,
          endAngle: -pi * 0.25 + pi * 2,
          stops: const [0.0, 0.15, 0.5, 1.0],
          colors: [
            Colors.white.withAlpha(60),
            Colors.white.withAlpha(15),
            Colors.white.withAlpha(3),
            Colors.white.withAlpha(60),
          ],
        ).createShader(
            Rect.fromLTWH(1, 1, size.width - 2, size.height - 2)),
    );

    // Top edge highlight — thin bright line
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(radius * 0.3, 0, size.width - radius * 0.6, 1),
        const Radius.circular(1),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withAlpha(0),
            Colors.white.withAlpha(120),
            Colors.white.withAlpha(120),
            Colors.white.withAlpha(0),
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ).createShader(
            Rect.fromLTWH(0, 0, size.width, 1)),
    );
  }

  @override
  bool shouldRepaint(_GlassRimPainter old) => old.t != t;
}
