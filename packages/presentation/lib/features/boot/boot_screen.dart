import 'dart:io';

import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:design_system/design_system.dart';
import '../onboarding/onboarding_screen.dart';

class BootScreen extends ConsumerStatefulWidget {
  const BootScreen({super.key});

  @override
  ConsumerState<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends ConsumerState<BootScreen>
    with TickerProviderStateMixin {
  late List<String> _lines;
  final List<String> _visible = [];
  bool _showPrompt = false;
  bool _showRestoreActions = false;
  bool _started = false;
  bool _isCheckingBackup = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    final l10n = context.l10n;
    _lines = [
      l10n.bootRunwayCheck,
      l10n.bootIncomeStopped,
      l10n.bootCountingCashDays,
      l10n.bootRemovingComfortFilter,
      l10n.bootRealityCheckReady,
      '',
      l10n.runwayBrand,
    ];
    _started = true;
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
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    if (!mounted) return;
    if (onboardingDone) {
      context.go('/dashboard');
    } else {
      setState(() => _showRestoreActions = true);
    }
  }

  Future<void> _continueToOnboarding() async {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  Future<void> _restoreFromBackup() async {
    final provider = await _chooseRestoreProvider();
    if (provider == null || !mounted) return;

    setState(() => _isCheckingBackup = true);
    try {
      final repository = ref.read(backupRepositoryProvider(provider));
      final metadata = await repository.getLatestBackup(provider);
      if (!mounted) return;

      if (metadata == null) {
        _showSnack('No backup found for this provider.');
        return;
      }

      final confirmed = await _confirmRestore(metadata);
      if (!confirmed || !mounted) return;

      await ref.read(backupProvider.notifier).restore(metadata);
      if (!mounted) return;
      _showSnack('Backup restored. Restart Runway to reload the database.');
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Restore failed: $e');
    } finally {
      if (mounted) setState(() => _isCheckingBackup = false);
    }
  }

  Future<BackupProvider?> _chooseRestoreProvider() {
    return showModalBottomSheet<BackupProvider>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) {
        final providers = <BackupProvider>[
          if (Platform.isIOS) BackupProvider.icloud,
          if (Platform.isAndroid) BackupProvider.google,
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Restore from backup', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.md),
                if (providers.isEmpty)
                  Text(
                    'Cloud backup is available on iOS and Android.',
                    style: AppTextStyles.bodySmall,
                  )
                else
                  for (final provider in providers)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(provider),
                        child: Text(
                          provider == BackupProvider.icloud
                              ? 'iCloud Backup'
                              : 'Google Backup',
                        ),
                      ),
                    ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmRestore(BackupMetadata metadata) async {
    final createdAt = metadata.createdAt.toLocal();
    final sizeMb = metadata.sizeBytes / (1024 * 1024);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('RESTORE DATA'),
            content: Text(
              '1 backup found\n'
              'Created: ${createdAt.day}/${createdAt.month}/${createdAt.year} '
              'on ${metadata.deviceId}\n'
              'Size: ${sizeMb.toStringAsFixed(1)} MB\n\n'
              'This will replace all current data. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('RESTORE DATA'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                      style: line == context.l10n.runwayBrand
                          ? AppTextStyles.metric
                          : AppTextStyles.value,
                    ),
                  ),
                ),
                if (_showPrompt) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _BlinkingCursor(),
                ],
                if (_showRestoreActions) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Welcome back — restore from backup?',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_isCheckingBackup)
                    const CircularProgressIndicator()
                  else ...[
                    FilledButton(
                      onPressed: _restoreFromBackup,
                      child: const Text('Restore Backup'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: _continueToOnboarding,
                      child: const Text('Continue without backup'),
                    ),
                  ],
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
