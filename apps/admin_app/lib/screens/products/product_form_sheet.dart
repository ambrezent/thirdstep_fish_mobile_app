import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../../providers/admin_providers.dart';

class ProductFormSheet extends ConsumerStatefulWidget {
  final Product? product;
  const ProductFormSheet({super.key, this.product});

  @override
  ConsumerState<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl, _nameArCtrl, _familyCtrl, _priceCtrl, _stockCtrl, _imageCtrl, _grossCtrl, _netCtrl;
  late String _category;
  late String _unit;
  late StockBadge _badge;
  late bool _preOrder;
  late List<FishCut> _cuts;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _nameArCtrl = TextEditingController(text: p?.nameAr ?? '');
    _familyCtrl = TextEditingController(text: p?.family ?? '');
    _priceCtrl = TextEditingController(text: p?.price.toString() ?? '');
    _stockCtrl = TextEditingController(text: p?.stockQty.toString() ?? '');
    _imageCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _grossCtrl = TextEditingController(text: p?.grossWeight.toString() ?? '');
    _netCtrl = TextEditingController(text: p?.netYield.toString() ?? '');
    _category = p?.category ?? 'large-fish';
    _unit = p?.unit ?? 'kg';
    _badge = p?.badge ?? StockBadge.inStock;
    _preOrder = p?.preOrder ?? false;
    _cuts = List.from(p?.cuts ?? [FishCut.whole]);
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _nameArCtrl, _familyCtrl, _priceCtrl, _stockCtrl, _imageCtrl, _grossCtrl, _netCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final isEdit = widget.product != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.all(20),
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text(isEdit ? 'Edit Product' : 'Add Product', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy)),
                const SizedBox(height: 20),

                TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'English Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 10),
                TextFormField(controller: _nameArCtrl, decoration: const InputDecoration(labelText: 'Arabic Name (الاسم العربي)'), textDirection: TextDirection.rtl),
                const SizedBox(height: 10),
                TextFormField(controller: _familyCtrl, decoration: const InputDecoration(labelText: 'Family Name (scientific)')),
                const SizedBox(height: 10),

                Row(children: [
                  Expanded(child: TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Price/kg (AED)', prefixText: 'AED '), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty ? 'Required' : null)),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(controller: _stockCtrl, decoration: const InputDecoration(labelText: 'Stock (kg)'), keyboardType: TextInputType.number)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextFormField(controller: _grossCtrl, decoration: const InputDecoration(labelText: 'Gross Weight (kg)'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(controller: _netCtrl, decoration: const InputDecoration(labelText: 'Net Yield (kg)'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                ]),
                const SizedBox(height: 10),
                TextFormField(controller: _imageCtrl, decoration: const InputDecoration(labelText: 'Image URL', prefixIcon: Icon(Icons.image_outlined))),
                const SizedBox(height: 16),

                // Category
                categoriesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (cats) => DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: cats.map((c) => DropdownMenuItem(value: c.slug, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<StockBadge>(
                  value: _badge,
                  decoration: const InputDecoration(labelText: 'Badge'),
                  items: StockBadge.values.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
                  onChanged: (v) => setState(() => _badge = v!),
                ),
                const SizedBox(height: 16),

                // Cuts
                const Text('Available Cuts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: FishCut.values.map((cut) {
                  final active = _cuts.contains(cut);
                  return GestureDetector(
                    onTap: () => setState(() => active ? _cuts.remove(cut) : _cuts.add(cut)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.gold.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: active ? AppColors.gold : AppColors.border),
                      ),
                      child: Text(cut.name, style: TextStyle(fontSize: 13, color: active ? AppColors.gold : AppColors.textSecondary, fontWeight: active ? FontWeight.w700 : FontWeight.normal)),
                    ),
                  );
                }).toList()),
                const SizedBox(height: 16),

                SwitchListTile(
                  value: _preOrder,
                  onChanged: (v) => setState(() => _preOrder = v),
                  title: const Text('Enable Pre-Order', style: TextStyle(fontWeight: FontWeight.w600)),
                  activeColor: AppColors.gold,
                  dense: true,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isEdit ? 'Save Changes' : 'Add Product', style: const TextStyle(fontSize: 15)),
                  ),
                ),
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

    final product = Product(
      id: widget.product?.id ?? '',
      name: _nameCtrl.text.trim(),
      nameAr: _nameArCtrl.text.trim(),
      family: _familyCtrl.text.trim(),
      category: _category,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      unit: _unit,
      stockQty: int.tryParse(_stockCtrl.text) ?? 0,
      grossWeight: double.tryParse(_grossCtrl.text) ?? 0,
      netYield: double.tryParse(_netCtrl.text) ?? 0,
      badge: _badge,
      imageUrl: _imageCtrl.text.trim(),
      preOrder: _preOrder,
      cuts: _cuts,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    try {
      final service = ref.read(firestoreServiceProvider);
      if (widget.product != null) {
        await service.updateProduct(product);
      } else {
        await service.addProduct(product);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.product != null ? 'Product updated!' : 'Product added!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
