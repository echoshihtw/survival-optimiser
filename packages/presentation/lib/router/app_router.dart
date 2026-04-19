import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/design_system.dart';
import '../features/boot/boot_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../features/scenarios/scenarios_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/boot',
  routes: [
    GoRoute(
      path: '/boot',
      builder: (_, __) => const BootScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) =>
          _ScaffoldWithNav(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/transactions',
            builder: (_, __) => const TransactionsScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/scenarios',
            builder: (_, __) => const ScenariosScreen(),
          ),
        ]),
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
      body: shell,
      bottomNavigationBar: _TerminalNavBar(
        currentIndex: shell.currentIndex,
        onTap: (i) => shell.goBranch(i),
      ),
    );
  }
}

class _TerminalNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TerminalNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (label: l10n.navHud, icon: '◈'),
      (label: l10n.navLog, icon: '≡'),
      (label: l10n.navSim, icon: '◇'),
    ];

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.panelBorder, width: 1),
        ),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final item   = items[i];
          final active = i == currentIndex;
          final color  = active
              ? AppColors.primaryGreen
              : AppColors.dimGreen;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.icon,
                      style: TextStyle(color: color, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(item.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontFamily: 'JetBrainsMono',
                      )),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
