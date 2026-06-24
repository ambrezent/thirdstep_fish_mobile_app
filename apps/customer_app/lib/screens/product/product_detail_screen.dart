import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import '../../providers/products_provider.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  FishCut? _selectedCut;
  double _quantity = 1.0;
  final List<String> _addons = [];
  final _notesController = TextEditingController();

  static const _addonOptions = [
    {'label': 'Ice Pack', 'emoji': '🧊'},
    {'label': 'Gift Box', 'emoji': '🎁'},
    {'label': 'Sayadieh Rice', 'emoji': '🍚'},
    {'label': 'Spice Mix', 'emoji': '🌶️'},
  ];

  static const _cutEmojis = {
    FishCut.whole: '🐟', FishCut.headOff: '✂️', FishCut.fillet: '🔪',
    FishCut.steaks: '🥩', FishCut.cubes: '🎲', FishCut.cleaned: '✨',
  };

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsStreamProvider).value ?? [];
    final product = products.cast<Product?>().firstWhere((p) => p?.id == widget.productId, orElse: () => null);

    if (product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 1.5)));
    }

    if (_selectedCut == null && product.cuts.isNotEmpty) _selectedCut = product.cuts.first;
    final totalPrice = product.price * _quantity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surfaceSecondary,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.navy, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.surfaceSecondary,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(child: Text('🐟', style: TextStyle(fontSize: 90))))
                    : const Center(child: Text('🐟', style: TextStyle(fontSize: 90))),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Container(
                height: 20,
                decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Title & Price
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(product.nameAr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2)),
                    const SizedBox(height: 3),
                    Text(product.name, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, letterSpacing: 0.3)),
                    if (product.family.isNotEmpty)
                      Text(product.family, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontStyle: FontStyle.italic)),
                  ])),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('AED ${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.gold)),
                    Text('per ${product.unit}', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary, letterSpacing: 0.3)),
                  ]),
                ]),
                const SizedBox(height: 12),

                // Info pills
                Row(children: [
                  _Pill('${product.grossWeight}kg gross'),
                  const SizedBox(width: 8),
                  _Pill('~${product.netYield}kg net'),
                  if (product.stockQty > 0) ...[
                    const SizedBox(width: 8),
                    _Pill('${product.stockQty}kg left', highlight: true),
                  ],
                ]),
                const SizedBox(height: 28),

                // Cut selector
                _Label('Select Cut'),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.7,
                  children: product.cuts.map((cut) {
                    final selected = _selectedCut == cut;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCut = cut),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.navy : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: selected ? AppColors.navy : AppColors.border),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(_cutEmojis[cut] ?? '🐟', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 3),
                          Text(
                            _cutLabel(cut),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondary, letterSpacing: 0.1),
                          ),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Quantity
                _Label('Quantity'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    _StepBtn(icon: Icons.remove, onTap: () => setState(() => _quantity = (_quantity - 0.5).clamp(0.5, 50))),
                    Expanded(child: Center(child: Text(
                      '$_quantity kg',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ))),
                    _StepBtn(icon: Icons.add, onTap: () => setState(() => _quantity += 0.5), filled: true),
                  ]),
                ),
                const SizedBox(height: 28),

                // Add-ons
                _Label('Add-ons'),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 3.4,
                  children: _addonOptions.map((a) {
                    final label = a['label']!;
                    final active = _addons.contains(label);
                    return GestureDetector(
                      onTap: () => setState(() => active ? _addons.remove(label) : _addons.add(label)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? AppColors.navy.withValues(alpha: 0.04) : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: active ? AppColors.navy : AppColors.border),
                        ),
                        child: Row(children: [
                          Text(a['emoji']!, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 7),
                          Expanded(child: Text(label, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? AppColors.textPrimary : AppColors.textSecondary))),
                          if (active) const Icon(Icons.check, color: AppColors.navy, size: 14),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Notes
                _Label('Kitchen Notes'),
                const SizedBox(height: 10),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Any special requests for the kitchen...',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.navy, width: 1.5)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Total', style: TextStyle(fontSize: 11, color: AppColors.textTertiary, letterSpacing: 0.3)),
            Text('AED ${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ]),
          const SizedBox(width: 20),
          Expanded(
            child: GestureDetector(
              onTap: product.isAvailable ? _addToCart : null,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: product.isAvailable ? AppColors.navy : AppColors.border,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    product.preOrder ? 'Pre-Order Now' : 'Add to Cart',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.2),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _addToCart() {
    final products = ref.read(productsStreamProvider).value ?? [];
    final product = products.firstWhere((p) => p.id == widget.productId);
    ref.read(cartProvider.notifier).addItem(CartItem(
      product: product,
      cut: _selectedCut ?? FishCut.whole,
      quantity: _quantity,
      addons: List.from(_addons),
      notes: _notesController.text,
    ));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${product.name} added to cart'),
      backgroundColor: AppColors.navy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      action: SnackBarAction(label: 'View Cart', textColor: AppColors.goldLight, onPressed: () => context.go('/cart')),
    ));
    context.pop();
  }

  String _cutLabel(FishCut cut) {
    switch (cut) {
      case FishCut.whole: return 'Whole'; case FishCut.headOff: return 'Head-off';
      case FishCut.fillet: return 'Fillet'; case FishCut.steaks: return 'Steaks';
      case FishCut.cubes: return 'Cubes'; case FishCut.cleaned: return 'Cleaned';
    }
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5),
  );
}

class _Pill extends StatelessWidget {
  final String text;
  final bool highlight;
  const _Pill(this.text, {this.highlight = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: highlight ? AppColors.gold.withValues(alpha: 0.08) : AppColors.surfaceSecondary,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: highlight ? AppColors.gold.withValues(alpha: 0.3) : AppColors.border),
    ),
    child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: highlight ? AppColors.goldDim : AppColors.textSecondary)),
  );
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _StepBtn({required this.icon, required this.onTap, this.filled = false});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: filled ? AppColors.navy : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: filled ? AppColors.navy : AppColors.border),
      ),
      child: Icon(icon, color: filled ? Colors.white : AppColors.textPrimary, size: 18),
    ),
  );
}
