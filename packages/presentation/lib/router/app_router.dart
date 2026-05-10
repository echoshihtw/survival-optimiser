import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/design_system.dart';
import '../features/boot/boot_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../features/scenarios/scenarios_screen.dart';

// Global keys for coach mark tour
final hudNavKey = GlobalKey();
final logNavKey = GlobalKey();
final simNavKey = GlobalKey();

final appRouter = GoRouter(
  initialLocation: '/boot',
  routes: [
    GoRoute(path: '/boot', builder: (_, __) => const BootScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _ScaffoldWithNav(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (_, __) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              builder: (_, __) => const TransactionsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scenarios',
              builder: (_, __) => const ScenariosScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class _ScaffoldWithNav extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _ScaffoldWithNav({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: shell,
      bottomNavigationBar: _NavBar(
        currentIndex: shell.currentIndex,
        onTap: (i) => shell.goBranch(i),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _NavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (label: l10n.navHud, icon: Icons.space_dashboard_rounded),
      (label: l10n.navLog, icon: Icons.receipt_long_rounded),
      (label: l10n.navSim, icon: Icons.science_rounded),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  key: i == 0
                      ? hudNavKey
                      : i == 1
                      ? logNavKey
                      : simNavKey,
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs + 2,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: active
                              ? AppColors.neonGreen
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: active
                                ? AppColors.neonGreen
                                : AppColors.textSecondary,
                            letterSpacing: 1.0,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 5),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOut,
                          width: active ? 18 : 0,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
