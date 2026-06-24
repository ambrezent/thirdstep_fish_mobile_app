import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../../providers/admin_providers.dart';

class AddWhatsAppOrderSheet extends ConsumerStatefulWidget {
  const AddWhatsAppOrderSheet({super.key});

  @override
  ConsumerState<AddWhatsAppOrderSheet> createState() => _AddWhatsAppOrderSheetState();
}

class _AddWhatsAppOrderSheetState extends ConsumerState<AddWhatsAppOrderSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  DeliveryType _deliveryType = DeliveryType.homeDelivery;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Row(children: [
                  const Text('💬', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  const Text('Log WhatsApp Order', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.navy)),
                ]),
                const SizedBox(height: 4),
                const Text('Manually add an order received via WhatsApp', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Customer Name', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _mobileCtrl,
                  decoration: const InputDecoration(labelText: 'WhatsApp Number', prefixIcon: Icon(Icons.phone_outlined)),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(labelText: 'Delivery Address', prefixIcon: Icon(Icons.location_on_outlined)),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _totalCtrl,
                  decoration: const InputDecoration(labelText: 'Order Total (AED)', prefixIcon: Icon(Icons.payments_outlined), prefixText: 'AED '),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(labelText: 'Order Notes / Items', prefixIcon: Icon(Icons.note_outlined)),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Delivery type
                Row(children: [
                  Expanded(child: RadioListTile<DeliveryType>(
                    title: const Text('Home Delivery', style: TextStyle(fontSize: 13)),
                    value: DeliveryType.homeDelivery,
                    groupValue: _deliveryType,
                    onChanged: (v) => setState(() => _deliveryType = v!),
                    dense: true,
                  )),
                  Expanded(child: RadioListTile<DeliveryType>(
                    title: const Text('Shop Pickup', style: TextStyle(fontSize: 13)),
                    value: DeliveryType.shopPickup,
                    groupValue: _deliveryType,
                    onChanged: (v) => setState(() => _deliveryType = v!),
                    dense: true,
                  )),
                ]),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whatsappGreen,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('💬  Log WhatsApp Order', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final total = double.tryParse(_totalCtrl.text) ?? 0;
    final fee = _deliveryType == DeliveryType.homeDelivery ? 15.0 : 0.0;

    final order = FishOrder(
      id: '',
      orderId: OrderIdGenerator.generate(),
      customerName: _nameCtrl.text.trim(),
      customerMobile: _mobileCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      items: [
        OrderItem(
          productId: 'manual',
          productName: _notesCtrl.text.isEmpty ? 'WhatsApp Order' : _notesCtrl.text,
          productNameAr: '',
          cut: FishCut.whole,
          quantity: 1,
          pricePerKg: total - fee,
          addons: [],
          notes: _notesCtrl.text,
        )
      ],
      deliveryType: _deliveryType,
      deliveryWindow: 'As agreed',
      subtotal: total - fee,
      deliveryFee: fee,
      total: total,
      status: OrderStatus.pending,
      paymentMethod: PaymentMethod.whatsappCod,
      source: OrderSource.whatsapp,
      codCollected: false,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(firestoreServiceProvider).placeOrder(order);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp order logged!'), backgroundColor: AppColors.whatsappGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
