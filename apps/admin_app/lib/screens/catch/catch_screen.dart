import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_providers.dart';

class CatchScreen extends ConsumerStatefulWidget {
  const CatchScreen({super.key});

  @override
  ConsumerState<CatchScreen> createState() => _CatchScreenState();
}

class _CatchScreenState extends ConsumerState<CatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _nameArCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _grossCtrl = TextEditingController();
  final _netCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  String _category = 'large-fish';
  StockBadge _badge = StockBadge.inStock;
  bool _pushing = false;
  final List<Map<String, dynamic>> _sessionCatches = [];

  @override
  void dispose() {
    for (final c in [_nameCtrl, _nameArCtrl, _priceCtrl, _grossCtrl, _netCtrl, _stockCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Catch Upload'),
            Text('Morning dock workflow', style: TextStyle(fontSize: 11, color: AppColors.goldLight)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.navy.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.navy.withOpacity(0.2))),
            child: const Row(children: [
              Text('🎣', style: TextStyle(fontSize: 24)),
              SizedBox(width: 10),
              Expanded(child: Text('Upload today\'s fresh catch. Items go live instantly on the customer app.', style: TextStyle(fontSize: 12, color: AppColors.navy))),
            ]),
          ),
          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Fish Name (English)', prefixIcon: Icon(Icons.water_outlined)), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameArCtrl,
                decoration: const InputDecoration(labelText: 'Fish Name (Arabic)', prefixIcon: Icon(Icons.translate)),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Price/kg', prefixText: 'AED '), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty ? 'Required' : null)),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _stockCtrl, decoration: const InputDecoration(labelText: 'Stock (kg)'), keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextFormField(controller: _grossCtrl, decoration: const InputDecoration(labelText: 'Gross Weight'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _netCtrl, decoration: const InputDecoration(labelText: 'Net Yield'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              ]),
              const SizedBox(height: 10),
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pushing ? null : _pushLive,
                  icon: _pushing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.rocket_launch_outlined),
                  label: const Text('Push Live', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                ),
              ),
            ]),
          ),

          if (_sessionCatches.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('This Session', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ..._sessionCatches.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.success.withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text('AED ${c['price']}/kg  •  ${c['stock']} kg stock', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ])),
                Text(DateFormat('h:mm a').format(c['time']), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            )),
          ],
        ],
      ),
    );
  }

  Future<void> _pushLive() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _pushing = true);

    final product = Product(
      id: '',
      name: _nameCtrl.text.trim(),
      nameAr: _nameArCtrl.text.trim(),
      family: '',
      category: _category,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      unit: 'kg',
      stockQty: int.tryParse(_stockCtrl.text) ?? 0,
      grossWeight: double.tryParse(_grossCtrl.text) ?? 0,
      netYield: double.tryParse(_netCtrl.text) ?? 0,
      badge: _badge,
      imageUrl: '',
      preOrder: false,
      cuts: [FishCut.whole, FishCut.cleaned, FishCut.fillet],
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(firestoreServiceProvider).addProduct(product);
      setState(() {
        _sessionCatches.insert(0, {
          'name': _nameCtrl.text.trim(),
          'price': _priceCtrl.text,
          'stock': _stockCtrl.text,
          'time': DateTime.now(),
        });
        _nameCtrl.clear(); _nameArCtrl.clear(); _priceCtrl.clear();
        _stockCtrl.clear(); _grossCtrl.clear(); _netCtrl.clear();
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎣 Catch pushed live!'), backgroundColor: AppColors.success));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _pushing = false);
    }
  }
}
