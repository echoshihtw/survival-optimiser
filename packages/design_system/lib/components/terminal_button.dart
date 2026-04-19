import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_text_styles.dart';
import '../tokens/app_spacing.dart';

class TerminalButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isDestructive;
  final bool fullWidth;
  final String? icon;

  const TerminalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.isDestructive = false,
    this.fullWidth = false,
    this.icon,
  });

  @override
  State<TerminalButton> createState() => _TerminalButtonState();
}

class _TerminalButtonState extends State<TerminalButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fillAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _fillAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _borderColor => widget.isDestructive
      ? AppColors.danger
      : (widget.color ?? AppColors.primaryGreen);

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.selectionClick();
    setState(() => _pressed = true);
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    setState(() => _pressed = false);
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _ctrl.reverse();
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: disabled ? null : _onTapDown,
      onTapUp: disabled ? null : _onTapUp,
      onTapCancel: disabled ? null : _onTapCancel,
      child: AnimatedBuilder(
        animation: _fillAnim,
        builder: (_, __) => Container(
          width: widget.fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: disabled
                  ? AppColors.dimGreen
                  : _borderColor,
              width: 1,
            ),
            color: disabled
                ? AppColors.background
                : _borderColor.withAlpha((_fillAnim.value * 30).toInt()),
          ),
          child: Row(
            mainAxisSize: widget.fullWidth
                ? MainAxisSize.max
                : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Text(widget.icon!,
                    style: TextStyle(
                      color: disabled ? AppColors.dimGreen : _borderColor,
                      fontSize: 14,
                    )),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                widget.label,
                style: AppTextStyles.value.copyWith(
                  color: disabled ? AppColors.dimGreen : _borderColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
