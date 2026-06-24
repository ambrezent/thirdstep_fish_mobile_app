import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shared/shared.dart';
import '../providers/cart_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final cartCount = ref.watch(cartProvider).length;

    int currentIndex = 0;
    if (location.startsWith('/cart')) currentIndex = 1;
    if (location.startsWith('/orders')) currentIndex = 2;
    if (location.startsWith('/profile')) currentIndex = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _NavItem(icon: Icons.storefront_outlined, activeIcon: Icons.storefront, label: 'Shop', index: 0, current: currentIndex, onTap: () => context.go('/')),
                _NavItem(
                  index: 1, current: currentIndex, label: 'Cart', onTap: () => context.go('/cart'),
                  icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag,
                  badge: cartCount > 0 ? cartCount : null,
                ),
                _NavItem(icon: Icons.receipt_outlined, activeIcon: Icons.receipt, label: 'Orders', index: 2, current: currentIndex, onTap: () => context.go('/orders')),
                _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', index: 3, current: currentIndex, onTap: () => context.go('/profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final VoidCallback onTap;
  final int? badge;

  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.index, required this.current, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          badges.Badge(
            showBadge: badge != null,
            badgeContent: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
            badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.gold, padding: EdgeInsets.all(3.5)),
            child: Icon(
              selected ? activeIcon : icon,
              color: selected ? AppColors.navy : AppColors.textTertiary,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? AppColors.navy : AppColors.textTertiary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: selected ? 16 : 0,
            height: 2,
            decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(1)),
          ),
        ]),
      ),
    );
  }
}
