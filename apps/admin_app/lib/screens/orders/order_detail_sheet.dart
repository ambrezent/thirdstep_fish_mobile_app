import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../../providers/admin_providers.dart';

class OrderDetailSheet extends ConsumerStatefulWidget {
  final FishOrder order;
  const OrderDetailSheet({super.key, required this.order});

  @override
  ConsumerState<OrderDetailSheet> createState() => _OrderDetailSheetState();
}

class _OrderDetailSheetState extends ConsumerState<OrderDetailSheet> {
  late OrderStatus _status;
  late bool _codCollected;
  double? _actualWeight;
  final _weightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
    _codCollected = widget.order.codCollected;
    _actualWeight = widget.order.actualWeight;
    if (_actualWeight != null) _weightCtrl.text = _actualWeight.toString();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final service = ref.read(firestoreServiceProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            // Handle
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(order.orderId, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy)),
              Text(order.source == OrderSource.whatsapp ? '💬 WhatsApp' : '📱 App',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 16),

            // Customer info
            _Section('Customer', [
              _Row('Name', order.customerName),
              _Row('Mobile', order.customerMobile),
              _Row('Address', order.address),
              _Row('Delivery', order.deliveryType == DeliveryType.homeDelivery ? 'Home Delivery' : 'Shop Pickup'),
              _Row('Window', order.deliveryWindow),
            ]),
            const SizedBox(height: 16),

            // Items
            _Section('Items', order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${item.productName} — ${item.cut.name}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${item.quantity} kg × AED ${item.pricePerKg.toStringAsFixed(2)}/kg = AED ${item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  if (item.addons.isNotEmpty) Text('Add-ons: ${item.addons.join(', ')}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  if (item.notes.isNotEmpty) Text('Notes: ${item.notes.toUpperCase()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy)),
                ]),
              ),
            )).toList()),
            const SizedBox(height: 16),

            // Actual weight adjuster
            _Section('Weight & Pricing', [
              TextField(
                controller: _weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Actual Weight (kg)',
                  suffixText: 'kg',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.save_outlined),
                    onPressed: () async {
                      final kg = double.tryParse(_weightCtrl.text);
                      if (kg != null) {
                        await service.updateActualWeight(order.id, kg);
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Weight updated')));
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _Row('Estimated Total', 'AED ${order.total.toStringAsFixed(2)}'),
              if (order.revisedTotal != null) _Row('Revised Total', 'AED ${order.revisedTotal!.toStringAsFixed(2)}', bold: true),
            ]),
            const SizedBox(height: 16),

            // COD Toggle
            if (order.isCod) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('COD Collected', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Switch(
                  value: _codCollected,
                  activeColor: AppColors.success,
                  onChanged: (v) async {
                    setState(() => _codCollected = v);
                    await service.markCodCollected(order.id, v);
                  },
                ),
              ]),
              const SizedBox(height: 16),
            ],

            // Status update
            _Section('Update Status', [
              DropdownButtonFormField<OrderStatus>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Order Status'),
                items: OrderStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                onChanged: (s) => setState(() => _status = s!),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await service.updateOrderStatus(order.id, _status);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated')));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Status'),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // Delete
            OutlinedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Delete Order?'),
                    content: Text('Delete ${order.orderId}?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await service.deleteOrder(order.id);
                  if (mounted) Navigator.pop(context);
                }
              },
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
              child: const Text('Delete Order'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.3)),
          const SizedBox(height: 8),
          ...children,
        ],
      );
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ]),
      );
}
