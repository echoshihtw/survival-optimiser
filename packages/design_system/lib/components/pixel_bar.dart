import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';

class PixelBar extends StatelessWidget {
  final double value;   // 0.0 to 1.0
  final Color color;
  final int segments;
  final double height;

  const PixelBar({
    super.key,
    required this.value,
    required this.color,
    this.segments = 20,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final filled = (value * segments).round().clamp(0, segments);

    return Row(
      children: List.generate(segments, (i) {
        final active = i < filled;
        return Expanded(
          child: Container(
            height: height,
            margin: EdgeInsets.only(
                right: i < segments - 1 ? 2 : 0),
            decoration: BoxDecoration(
              color: active
                  ? color
                  : AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      }),
    );
  }
}
