import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);
    final productsAsync = ref.watch(productsStreamProvider);
    final pendingAsync = ref.watch(pendingOrdersProvider);
    final revenueAsync = ref.watch(totalRevenueProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        strokeWidth: 1.5,
        onRefresh: () async => ref.invalidate(ordersStreamProvider),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 170,
              pinned: true,
              backgroundColor: AppColors.primary,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: SafeArea(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 14),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Row(children: [
                          Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: AppColors.primary.withValues(alpha: 0.15),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                            ),
                            child: const Center(child: Text('🐟', style: TextStyle(fontSize: 17))),
                          ),
                          const SizedBox(width: 10),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Third Step', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                            Text('Admin Portal', style: TextStyle(color: AppColors.primary.withValues(alpha: 0.7), fontSize: 9, letterSpacing: 0.8)),
                          ]),
                        ]),
                        GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(Icons.notifications_none, color: Colors.white, size: 18),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 22),
                      Text(
                        'Good ${_greeting()},',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w300, letterSpacing: -0.3),
                      ),
                      Text(
                        DateFormat('EEEE, d MMMM').format(DateTime.now()),
                        style: TextStyle(color: AppColors.primary.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.2),
                      ),
                    ]),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: Container(
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stat grid
                  GridView.count(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.65,
                    children: [
                      _StatCard(
                        label: 'Products',
                        icon: Icons.inventory_2_outlined,
                        value: productsAsync.when(data: (p) => '${p.length}', loading: () => '—', error: (_, __) => '—'),
                        onTap: () => context.go('/products'),
                      ),
                      _StatCard(
                        label: 'Total Orders',
                        icon: Icons.receipt_outlined,
                        value: ordersAsync.when(data: (o) => '${o.length}', loading: () => '—', error: (_, __) => '—'),
                        accent: AppColors.primary,
                        onTap: () => context.go('/orders'),
                      ),
                      _StatCard(
                        label: 'Pending',
                        icon: Icons.schedule_outlined,
                        value: pendingAsync.when(data: (o) => '${o.length}', loading: () => '—', error: (_, __) => '—'),
                        accent: const Color(0xFFD97706),
                        onTap: () => context.go('/orders'),
                      ),
                      _StatCard(
                        label: 'Revenue',
                        icon: Icons.trending_up,
                        value: revenueAsync.when(data: (r) => 'AED ${r.toStringAsFixed(0)}', loading: () => '—', error: (_, __) => '—'),
                        accent: AppColors.success,
                        small: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick actions
                  _SectionTitle('Quick Actions'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _ActionBtn(label: 'Upload Catch', icon: Icons.waves_outlined, onTap: () => context.go('/catch'))),
                    const SizedBox(width: 8),
                    Expanded(child: _ActionBtn(label: 'Log WA Order', icon: Icons.chat_outlined, onTap: () => context.go('/orders'), gold: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _ActionBtn(label: 'Add Fish', icon: Icons.add_circle_outline, onTap: () => context.go('/products'))),
                  ]),
                  const SizedBox(height: 24),

                  // Pending alert
                  pendingAsync.when(
                    data: (pending) => pending.isEmpty ? const SizedBox.shrink() : _PendingBanner(count: pending.length, onTap: () => context.go('/orders')),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // Recent orders
                  _SectionTitle('Recent Orders', action: 'View all', onAction: () => context.go('/orders')),
                  const SizedBox(height: 10),

                  ordersAsync.when(
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1.5))),
                    error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.error)),
                    data: (orders) => Column(
                      children: orders.take(5).map((o) => _RecentOrderTile(o)).toList(),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionTitle(this.title, {this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.2)),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
    ],
  );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color? accent;
  final VoidCallback? onTap;
  final bool small;
  const _StatCard({required this.label, required this.icon, required this.value, this.accent, this.onTap, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(icon, size: 18, color: color.withValues(alpha: 0.7)),
            if (onTap != null) Icon(Icons.arrow_forward, size: 12, color: AppColors.textTertiary),
          ]),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: small ? 14 : 22, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool gold;
  const _ActionBtn({required this.label, required this.icon, required this.onTap, this.gold = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: gold ? AppColors.primary : AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.1), textAlign: TextAlign.center),
      ]),
    ),
  );
}

class _PendingBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _PendingBanner({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.35)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.schedule_outlined, size: 18, color: Color(0xFFD97706)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '$count order${count > 1 ? 's' : ''} need attention',
            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFD97706), fontSize: 13),
          ),
          const Text('Tap to review and confirm', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textTertiary),
      ]),
    ),
  );
}

class _RecentOrderTile extends StatelessWidget {
  final FishOrder order;
  const _RecentOrderTile(this.order);

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: order.source == OrderSource.whatsapp ? const Color(0xFFE7FAF0) : AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            order.source == OrderSource.whatsapp ? Icons.chat_outlined : Icons.smartphone_outlined,
            size: 17,
            color: order.source == OrderSource.whatsapp ? AppColors.whatsappGreen : AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary, letterSpacing: 0.1)),
          Text(order.customerName, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('AED ${order.displayTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(order.status.name, style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
          ),
        ]),
      ]),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return AppColors.warning;
      case OrderStatus.confirmed: return AppColors.info;
      case OrderStatus.preparing: return const Color(0xFF7C3AED);
      case OrderStatus.outForDelivery: return AppColors.warning;
      case OrderStatus.delivered: return AppColors.success;
      case OrderStatus.cancelled: return AppColors.error;
    }
  }
}
