import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../../providers/products_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, filter by saved customer mobile. For now show all.
    final ordersAsync = ref.watch(firestoreServiceProvider).ordersStream();

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<List<FishOrder>>(
        stream: ordersAsync,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snap.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('📋', style: TextStyle(fontSize: 64)),
                SizedBox(height: 12),
                Text('No orders yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              ]),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final FishOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy, fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(_statusLabel(order.status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ]),
        const SizedBox(height: 8),
        Text('${order.items.length} item(s) · ${order.deliveryWindow}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('AED ${order.displayTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.gold)),
          Text(order.paymentMethod == PaymentMethod.whatsappCod ? '💵 COD' : '💳 Paid',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 12),
        // Status steps
        _StatusTracker(order.status),
      ]),
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

class _StatusTracker extends StatelessWidget {
  final OrderStatus status;
  const _StatusTracker(this.status);

  @override
  Widget build(BuildContext context) {
    final steps = [OrderStatus.confirmed, OrderStatus.preparing, OrderStatus.outForDelivery, OrderStatus.delivered];
    final currentIdx = steps.indexOf(status);

    return Row(
      children: steps.asMap().entries.map((e) {
        final idx = e.key;
        final step = e.value;
        final done = currentIdx >= idx;
        return Expanded(
          child: Row(children: [
            Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                color: done ? AppColors.navy : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: done ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
            ),
            if (idx < steps.length - 1)
              Expanded(child: Container(height: 2, color: done && currentIdx > idx ? AppColors.navy : AppColors.border)),
          ]),
        );
      }).toList(),
    );
  }
}
