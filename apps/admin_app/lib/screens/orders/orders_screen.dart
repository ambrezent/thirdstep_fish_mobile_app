import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_providers.dart';
import 'add_whatsapp_order_sheet.dart';
import 'order_detail_sheet.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(orderSourceFilterProvider);
    final ordersAsync = ref.watch(filteredOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: AppColors.whatsappGreen),
            tooltip: 'Log WhatsApp Order',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const AddWhatsAppOrderSheet(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Source filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              _FilterChip('All', filter == null, () => ref.read(orderSourceFilterProvider.notifier).state = null),
              const SizedBox(width: 8),
              _FilterChip('📱 App', filter == OrderSource.app, () => ref.read(orderSourceFilterProvider.notifier).state = OrderSource.app),
              const SizedBox(width: 8),
              _FilterChip('💬 WhatsApp', filter == OrderSource.whatsapp, () => ref.read(orderSourceFilterProvider.notifier).state = OrderSource.whatsapp),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (orders) {
                if (orders.isEmpty) {
                  return const Center(child: Text('No orders', style: TextStyle(color: AppColors.textSecondary)));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _AdminOrderCard(
                    order: orders[i],
                    onTap: () => showModalBottomSheet(
                      context: ctx,
                      isScrollControlled: true,
                      builder: (_) => OrderDetailSheet(order: orders[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.gold : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppColors.gold : AppColors.border),
          ),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondary)),
        ),
      );
}

class _AdminOrderCard extends StatelessWidget {
  final FishOrder order;
  final VoidCallback onTap;
  const _AdminOrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(order.source == OrderSource.whatsapp ? '💬' : '📱', style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(child: Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(_statusLabel(order.status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(order.customerName, style: const TextStyle(fontSize: 13)),
            const Spacer(),
            Text(DateFormat('d MMM · h:mm a').format(order.createdAt),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(order.customerMobile, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const Spacer(),
            Text('AED ${order.displayTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.gold, fontSize: 14)),
          ]),
          if (order.isCod) ...[
            const SizedBox(height: 8),
            Row(children: [
              Icon(order.codCollected ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 14, color: order.codCollected ? AppColors.success : AppColors.warning),
              const SizedBox(width: 4),
              Text(order.codCollected ? 'COD Collected' : 'COD Pending',
                  style: TextStyle(fontSize: 11, color: order.codCollected ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w600)),
            ]),
          ],
        ]),
      ),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return const Color(0xFFD97706);
      case OrderStatus.confirmed: return const Color(0xFF1D4ED8);
      case OrderStatus.preparing: return const Color(0xFF5B21B6);
      case OrderStatus.outForDelivery: return const Color(0xFFD97706);
      case OrderStatus.delivered: return AppColors.success;
      case OrderStatus.cancelled: return AppColors.error;
    }
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }
}
