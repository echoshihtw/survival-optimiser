import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/design_system.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> with TickerProviderStateMixin {
  final List<String> _lines = [
    '> INITIALIZING SURVIVAL.EXE...',
    '> LOADING ASSET DATABASE...',
    '> CALIBRATING BURN RATE...',
    '> COMPUTING SURVIVAL MODEL...',
    '> SYSTEM ONLINE.',
    '',
    'SURVIVAL OPTIMIZER v1.0',
  ];

  final List<String> _visible = [];
  bool _showPrompt = false;

  @override
  void initState() {
    super.initState();
    _runBootSequence();
  }

  Future<void> _runBootSequence() async {
    for (final line in _lines) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _visible.add(line));
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _showPrompt = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ScanlineOverlay(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                ..._visible.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      line,
                      style: line.startsWith('SURVIVAL')
                          ? AppTextStyles.metric
                          : AppTextStyles.value,
                    ),
                  ),
                ),
                if (_showPrompt) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _BlinkingCursor(),
                ],
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
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
      builder: (_, __) =>
          Text(_ctrl.value > 0.5 ? '█' : ' ', style: AppTextStyles.value),
    );
  }
}
