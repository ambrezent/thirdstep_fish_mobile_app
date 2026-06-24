import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    const deliveryFee = 15.0;
    final total = subtotal + deliveryFee;

    if (cart.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          title: const Text('Cart'),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 88, height: 88,
              decoration: const BoxDecoration(color: AppColors.surfaceSecondary, shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.shopping_bag_outlined, size: 38, color: AppColors.textTertiary)),
            ),
            const SizedBox(height: 20),
            const Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('Add fresh fish to get started', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => context.go('/'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(12)),
                child: const Text('Browse Fish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text('Cart  (${cart.length})', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () => _showClearDialog(context, ref),
            child: const Text('Clear', style: TextStyle(color: Colors.white54, fontSize: 13)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: cart.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _CartItemCard(index: i, item: cart[i]),
            ),
          ),

          // Summary
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: [
              _Row('Subtotal', 'AED ${subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _Row('Delivery', 'AED ${deliveryFee.toStringAsFixed(2)}'),
              const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('AED ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gold)),
              ]),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.push('/checkout'),
                child: Container(
                  width: double.infinity, height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text('Proceed to Checkout', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2))),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cart?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Remove all items?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () { ref.read(cartProvider.notifier).clear(); Navigator.pop(c); },
            child: const Text('Clear', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  final int index;
  final CartItem item;
  const _CartItemCard({required this.index, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: item.product.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(item.product.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(child: Text('🐟', style: TextStyle(fontSize: 26)))))
                : const Center(child: Text('🐟', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.product.nameAr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(item.product.name, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Row(children: [
                _Tag(item.cut.name),
                if (item.addons.isNotEmpty) ...[
                  const SizedBox(width: 5),
                  _Tag('+${item.addons.length} add-on${item.addons.length > 1 ? 's' : ''}'),
                ],
              ]),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('AED ${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gold)),
                Row(children: [
                  _QtyBtn(icon: Icons.remove, onTap: () => ref.read(cartProvider.notifier).updateQuantity(index, item.quantity - 0.5)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('${item.quantity}kg', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                  _QtyBtn(icon: Icons.add, onTap: () => ref.read(cartProvider.notifier).updateQuantity(index, item.quantity + 0.5), filled: true),
                ]),
              ]),
            ]),
          ),
          GestureDetector(
            onTap: () => ref.read(cartProvider.notifier).removeItem(index),
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.close, color: AppColors.textTertiary, size: 18),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.surfaceSecondary,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
  );
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _QtyBtn({required this.icon, required this.onTap, this.filled = false});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: filled ? AppColors.navy : AppColors.surface,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: filled ? AppColors.navy : AppColors.border),
      ),
      child: Icon(icon, size: 14, color: filled ? Colors.white : AppColors.textPrimary),
    ),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.textPrimary)),
  ]);
}
