import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _driverNotesCtrl = TextEditingController();

  DeliveryType _deliveryType = DeliveryType.homeDelivery;
  PaymentMethod _paymentMethod = PaymentMethod.whatsappCod;
  String _selectedWindow = 'Tomorrow AM';
  bool _isPlacing = false;

  static const _deliveryWindows = ['Today PM', 'Tomorrow AM', 'Tomorrow PM', 'Day After AM', 'Day After PM'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    _driverNotesCtrl.dispose();
    super.dispose();
  }

  double get _subtotal => ref.read(cartSubtotalProvider);
  double get _deliveryFee => _deliveryType == DeliveryType.homeDelivery ? 15.0 : 0.0;
  double get _total => _subtotal + _deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionTitle('Customer Details'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _mobileCtrl,
              decoration: const InputDecoration(labelText: 'WhatsApp Number', prefixIcon: Icon(Icons.phone_outlined), prefixText: '+971 '),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            _SectionTitle('Delivery'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _DeliveryOption(
                label: 'Home Delivery', sub: 'AED 15.00', icon: Icons.delivery_dining,
                selected: _deliveryType == DeliveryType.homeDelivery,
                onTap: () => setState(() => _deliveryType = DeliveryType.homeDelivery),
              )),
              const SizedBox(width: 10),
              Expanded(child: _DeliveryOption(
                label: 'Shop Pickup', sub: 'Free', icon: Icons.store_outlined,
                selected: _deliveryType == DeliveryType.shopPickup,
                onTap: () => setState(() => _deliveryType = DeliveryType.shopPickup),
              )),
            ]),
            if (_deliveryType == DeliveryType.homeDelivery) ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Delivery Address', prefixIcon: Icon(Icons.location_on_outlined)),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
            const SizedBox(height: 16),

            // Delivery window
            const Text('Delivery Window', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _deliveryWindows.map((w) {
              final sel = _selectedWindow == w;
              return GestureDetector(
                onTap: () => setState(() => _selectedWindow = w),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.navy : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: sel ? AppColors.navy : AppColors.border),
                  ),
                  child: Text(w, style: TextStyle(fontSize: 12, color: sel ? Colors.white : AppColors.textSecondary, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                ),
              );
            }).toList()),
            const SizedBox(height: 16),

            TextFormField(
              controller: _driverNotesCtrl,
              decoration: const InputDecoration(labelText: 'Driver Notes (optional)', prefixIcon: Icon(Icons.note_outlined)),
            ),
            const SizedBox(height: 24),

            // Payment Method
            _SectionTitle('Payment Method'),
            const SizedBox(height: 10),
            _PaymentOption(
              icon: '💬',
              title: 'WhatsApp Order + Cash on Delivery',
              subtitle: 'Order via WhatsApp · Pay when delivered',
              selected: _paymentMethod == PaymentMethod.whatsappCod,
              onTap: () => setState(() => _paymentMethod = PaymentMethod.whatsappCod),
              color: AppColors.whatsappGreen,
            ),
            const SizedBox(height: 10),
            _PaymentOption(
              icon: '💳',
              title: 'Online Payment',
              subtitle: 'Card · Apple Pay · Tap',
              selected: _paymentMethod == PaymentMethod.onlinePayment,
              onTap: () => setState(() => _paymentMethod = PaymentMethod.onlinePayment),
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(height: 24),

            // Order summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Column(children: [
                _SummaryRow('Subtotal', 'AED ${_subtotal.toStringAsFixed(2)}'),
                _SummaryRow('Delivery', _deliveryFee > 0 ? 'AED ${_deliveryFee.toStringAsFixed(2)}' : 'Free'),
                const Divider(height: 16),
                _SummaryRow('Total', 'AED ${_total.toStringAsFixed(2)}', bold: true),
              ]),
            ),
            const SizedBox(height: 20),

            // Note for WhatsApp
            if (_paymentMethod == PaymentMethod.whatsappCod)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7FAE7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.whatsappGreen.withOpacity(0.4)),
                ),
                child: const Row(children: [
                  Text('💬', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Expanded(child: Text('Your order will open WhatsApp. Send the message to confirm your order.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF2e7d32)))),
                ]),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isPlacing ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              backgroundColor: _paymentMethod == PaymentMethod.whatsappCod ? AppColors.whatsappGreen : AppColors.navy,
            ),
            child: _isPlacing
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    _paymentMethod == PaymentMethod.whatsappCod
                        ? '💬  Place Order via WhatsApp'
                        : '💳  Pay AED ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isPlacing = true);

    final cart = ref.read(cartProvider);
    final orderId = OrderIdGenerator.generate();

    final order = FishOrder(
      id: '',
      orderId: orderId,
      customerName: _nameCtrl.text.trim(),
      customerMobile: '+971${_mobileCtrl.text.trim()}',
      address: _addressCtrl.text.trim(),
      items: cart.map((c) => OrderItem(
            productId: c.product.id,
            productName: c.product.name,
            productNameAr: c.product.nameAr,
            cut: c.cut,
            quantity: c.quantity,
            pricePerKg: c.product.price,
            addons: c.addons,
            notes: c.notes,
          )).toList(),
      deliveryType: _deliveryType,
      deliveryWindow: _selectedWindow,
      subtotal: _subtotal,
      deliveryFee: _deliveryFee,
      total: _total,
      status: OrderStatus.pending,
      paymentMethod: _paymentMethod,
      source: OrderSource.app,
      codCollected: false,
      createdAt: DateTime.now(),
    );

    try {
      final service = ref.read(firestoreServiceProvider);
      await service.placeOrder(order);

      if (_paymentMethod == PaymentMethod.whatsappCod) {
        await WhatsAppHelper.sendOrder(order);
      }

      ref.read(cartProvider.notifier).clear();

      if (mounted) {
        context.go('/orders');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navy));
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _SummaryRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: bold ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: bold ? FontWeight.w700 : FontWeight.normal, fontSize: bold ? 16 : 14)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600, fontSize: bold ? 16 : 14, color: bold ? AppColors.navy : AppColors.textPrimary)),
        ],
      );
}

class _DeliveryOption extends StatelessWidget {
  final String label, sub;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _DeliveryOption({required this.label, required this.sub, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? AppColors.navy.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? AppColors.navy : AppColors.border, width: selected ? 2 : 1),
          ),
          child: Column(children: [
            Icon(icon, color: selected ? AppColors.navy : AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? AppColors.navy : AppColors.textPrimary)),
            Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ),
      );
}

class _PaymentOption extends StatelessWidget {
  final String icon, title, subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _PaymentOption({required this.icon, required this.title, required this.subtitle, required this.selected, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.06) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? color : AppColors.border, width: selected ? 2 : 1),
          ),
          child: Row(children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selected ? color : AppColors.textPrimary)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ])),
            if (selected) Icon(Icons.check_circle, color: color, size: 20),
          ]),
        ),
      );
}
