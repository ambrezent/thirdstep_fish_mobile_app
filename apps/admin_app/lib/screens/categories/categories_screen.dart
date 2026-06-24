import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../../providers/admin_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showForm(context, ref, null),
          ),
        ],
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cats) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: cats.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) => _CategoryTile(category: cats[i], ref: ref, context: context),
        ),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, FishCategory? cat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CategoryForm(category: cat, ref: ref),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final FishCategory category;
  final WidgetRef ref;
  final BuildContext context;
  const _CategoryTile({required this.category, required this.ref, required this.context});

  @override
  Widget build(BuildContext _) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: _hexColor(category.color).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Container(width: 16, height: 16, decoration: BoxDecoration(color: _hexColor(category.color), shape: BoxShape.circle))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(category.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          Text(category.nameAr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text('/${category.slug}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'monospace')),
        ])),
        PopupMenuButton<String>(
          onSelected: (action) async {
            if (action == 'edit') {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => _CategoryForm(category: category, ref: ref),
              );
            } else if (action == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Delete Category?'),
                  content: const Text('This may affect products using this category.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              );
              if (confirm == true) await ref.read(firestoreServiceProvider).deleteCategory(category.id);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
          ],
        ),
      ]),
    );
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.navy;
    }
  }
}

class _CategoryForm extends ConsumerStatefulWidget {
  final FishCategory? category;
  final WidgetRef ref;
  const _CategoryForm({this.category, required this.ref});

  @override
  ConsumerState<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<_CategoryForm> {
  late TextEditingController _nameCtrl, _nameArCtrl, _slugCtrl;
  String _color = '#1A3A5C';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _nameArCtrl = TextEditingController(text: c?.nameAr ?? '');
    _slugCtrl = TextEditingController(text: c?.slug ?? '');
    _color = c?.color ?? '#1A3A5C';
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _nameArCtrl.dispose(); _slugCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text(widget.category != null ? 'Edit Category' : 'Add Category', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.navy)),
          const SizedBox(height: 16),
          TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name (English)')),
          const SizedBox(height: 10),
          TextFormField(controller: _nameArCtrl, decoration: const InputDecoration(labelText: 'Name (Arabic)'), textDirection: TextDirection.rtl),
          const SizedBox(height: 10),
          TextFormField(
            controller: _slugCtrl,
            decoration: const InputDecoration(labelText: 'Slug (url-safe)', prefixText: '/'),
            readOnly: widget.category != null,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: _saving ? const CircularProgressIndicator(color: Colors.white) : Text(widget.category != null ? 'Save' : 'Add Category'),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final cat = FishCategory(
      id: widget.category?.id ?? '',
      name: _nameCtrl.text.trim(),
      nameAr: _nameArCtrl.text.trim(),
      slug: _slugCtrl.text.trim().toLowerCase().replaceAll(' ', '-'),
      color: _color,
      createdAt: widget.category?.createdAt ?? DateTime.now(),
    );
    try {
      final service = ref.read(firestoreServiceProvider);
      if (widget.category != null) {
        await service.updateCategory(cat);
      } else {
        await service.addCategory(cat);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
