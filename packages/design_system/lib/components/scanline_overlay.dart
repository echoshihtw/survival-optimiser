import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';

/// Renders a subtle CRT scanline effect over any widget.
/// Usage: ScanlineOverlay(child: yourWidget)
class ScanlineOverlay extends StatelessWidget {
  final Widget child;
  final double lineHeight;
  final double lineSpacing;

  const ScanlineOverlay({
    super.key,
    required this.child,
    this.lineHeight = 1.0,
    this.lineSpacing = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ScanlinePainter(
                lineHeight: lineHeight,
                lineSpacing: lineSpacing,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double lineHeight;
  final double lineSpacing;

  const _ScanlinePainter({required this.lineHeight, required this.lineSpacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.scanline
      ..strokeWidth = lineHeight;

    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += lineHeight + lineSpacing;
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter old) =>
      old.lineHeight != lineHeight || old.lineSpacing != lineSpacing;
}
