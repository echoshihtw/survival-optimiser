import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/app_spacing.dart';

class LiquidGlassContainer extends StatefulWidget {
  final Widget child;
  final Color accentColor;
  final double borderRadius;
  final EdgeInsets padding;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    required this.accentColor,
    this.borderRadius = AppSpacing.cardRadius,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
  });

  @override
  State<LiquidGlassContainer> createState() =>
      _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
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
      builder: (_, child) {
        return ClipRRect(
          borderRadius:
              BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
            child: CustomPaint(
              foregroundPainter: _RimPainter(
                t: _ctrl.value,
                accentColor: widget.accentColor,
                radius: widget.borderRadius,
              ),
              painter: _BodyPainter(
                t: _ctrl.value,
                accentColor: widget.accentColor,
              ),
              child: Padding(
                padding: widget.padding,
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _BodyPainter extends CustomPainter {
  final double t;
  final Color accentColor;

  _BodyPainter({required this.t, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect  = Offset.zero & size;

    // Base fill
    canvas.drawRect(rect, Paint()
      ..color = const Color(0xFF111318).withAlpha(80));

    // Top light scatter
    canvas.drawRect(rect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.5, 1.0],
        colors: [
          Colors.white.withAlpha(14),
          Colors.white.withAlpha(4),
          Colors.white.withAlpha(0),
        ],
      ).createShader(rect));

    // Accent tint
    canvas.drawRect(rect, Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.8),
        radius: 1.0,
        colors: [
          accentColor.withAlpha(18),
          accentColor.withAlpha(0),
        ],
      ).createShader(rect));

    // Bottom depth shadow
    canvas.drawRect(rect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        stops: const [0.0, 0.25],
        colors: [
          Colors.black.withAlpha(25),
          Colors.black.withAlpha(0),
        ],
      ).createShader(rect));

    // Slow shimmer
    final sx = 0.5 + cos(t * 2 * pi) * 0.25;
    final sy = 0.35 + sin(t * pi) * 0.15;
    canvas.drawRect(rect, Paint()
      ..shader = RadialGradient(
        center: Alignment(sx * 2 - 1, sy * 2 - 1),
        radius: 0.7,
        colors: [
          Colors.white.withAlpha(
              (10 * (0.5 + 0.5 * sin(t * 2 * pi))).round()),
          Colors.white.withAlpha(0),
        ],
      ).createShader(rect));
  }

  @override
  bool shouldRepaint(_BodyPainter old) => old.t != t;
}

class _RimPainter extends CustomPainter {
  final double t;
  final Color accentColor;
  final double radius;

  _RimPainter({
    required this.t,
    required this.accentColor,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect  = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
        rect, Radius.circular(radius));

    // Outer rim — sweep gradient, light from upper-left 45°
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = SweepGradient(
          center: Alignment.topLeft,
          startAngle: -pi * 0.25,
          endAngle: -pi * 0.25 + pi * 2,
          stops: const [0.0, 0.06, 0.2, 0.5, 0.8, 0.94, 1.0],
          colors: [
            Colors.white.withAlpha(200),
            Colors.white.withAlpha(90),
            Colors.white.withAlpha(18),
            Colors.white.withAlpha(6),
            Colors.white.withAlpha(10),
            Colors.white.withAlpha(50),
            Colors.white.withAlpha(200),
          ],
        ).createShader(rect),
    );

    // Inner rim — 1px inset
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      Radius.circular(radius - 1),
    );
    canvas.drawRRect(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..shader = SweepGradient(
          center: Alignment.topLeft,
          startAngle: -pi * 0.25,
          endAngle: -pi * 0.25 + pi * 2,
          stops: const [0.0, 0.12, 0.5, 1.0],
          colors: [
            Colors.white.withAlpha(70),
            Colors.white.withAlpha(18),
            Colors.white.withAlpha(3),
            Colors.white.withAlpha(70),
          ],
        ).createShader(
            Rect.fromLTWH(1, 1, size.width - 2, size.height - 2)),
    );

    // Top edge bright line
    final topLine = RRect.fromRectAndRadius(
      Rect.fromLTWH(radius * 0.5, 0.5,
          size.width - radius, 0.5),
      const Radius.circular(1),
    );
    canvas.drawRRect(
      topLine,
      Paint()
        ..shader = LinearGradient(
          stops: const [0.0, 0.15, 0.85, 1.0],
          colors: [
            Colors.white.withAlpha(0),
            Colors.white.withAlpha(140),
            Colors.white.withAlpha(140),
            Colors.white.withAlpha(0),
          ],
        ).createShader(rect),
    );

    // Left edge bright line
    final leftLine = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, radius * 0.5,
          0.5, size.height - radius),
      const Radius.circular(1),
    );
    canvas.drawRRect(
      leftLine,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.15, 0.85, 1.0],
          colors: [
            Colors.white.withAlpha(0),
            Colors.white.withAlpha(80),
            Colors.white.withAlpha(20),
            Colors.white.withAlpha(0),
          ],
        ).createShader(
            Rect.fromLTWH(0, 0, 1, size.height)),
    );
  }

  @override
  bool shouldRepaint(_RimPainter old) => old.t != t;
}
