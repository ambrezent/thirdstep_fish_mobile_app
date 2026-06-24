import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith('/orders')) currentIndex = 1;
    if (location.startsWith('/products')) currentIndex = 2;
    if (location.startsWith('/catch')) currentIndex = 3;
    if (location.startsWith('/categories')) currentIndex = 4;
    if (location.startsWith('/settings')) currentIndex = 5;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(children: [
              _AdminNavItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded, label: 'Dashboard', index: 0, current: currentIndex, onTap: () => context.go('/dashboard')),
              _AdminNavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Orders', index: 1, current: currentIndex, onTap: () => context.go('/orders')),
              _AdminNavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Products', index: 2, current: currentIndex, onTap: () => context.go('/products')),
              _AdminNavItem(icon: Icons.waves_outlined, activeIcon: Icons.waves, label: 'Catch', index: 3, current: currentIndex, onTap: () => context.go('/catch')),
              _AdminNavItem(icon: Icons.label_outline, activeIcon: Icons.label, label: 'Categories', index: 4, current: currentIndex, onTap: () => context.go('/categories')),
              _AdminNavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings', index: 5, current: currentIndex, onTap: () => context.go('/settings')),
            ]),
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final VoidCallback onTap;
  const _AdminNavItem({required this.icon, required this.activeIcon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36, height: 26,
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryLight : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              selected ? activeIcon : icon,
              color: selected ? AppColors.primary : AppColors.textTertiary,
              size: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? AppColors.primary : AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ]),
      ),
    );
  }
}
