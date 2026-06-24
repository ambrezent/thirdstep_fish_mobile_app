import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../providers/products_provider.dart';

const _categoryEmojis = {
  'large-fish': '🐟',
  'small-fish': '🐠',
  'shellfish': '🦞',
  'shrimp': '🦐',
  'pre-orders': '📦',
};

class CategoryChipBar extends ConsumerWidget {
  final String? selected;
  final ValueChanged<String>? onSelected;

  const CategoryChipBar({super.key, this.selected, this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final providerSelected = ref.watch(selectedCategoryProvider);
    final activeSelected = selected ?? providerSelected;

    return categoriesAsync.when(
      loading: () => const SizedBox(height: 44),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) => SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: 16),
          children: [
            _PillChip(
              emoji: '🌊',
              label: 'All Fish',
              selected: activeSelected == null || activeSelected == 'All',
              onTap: () {
                ref.read(selectedCategoryProvider.notifier).state = null;
                onSelected?.call('All');
              },
            ),
            ...categories.map((c) => _PillChip(
                  emoji: _categoryEmojis[c.slug] ?? '🐟',
                  label: c.name,
                  selected: activeSelected == c.slug,
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = c.slug;
                    onSelected?.call(c.slug);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String emoji, label;
  final bool selected;
  final VoidCallback onTap;
  const _PillChip({required this.emoji, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ]),
      ),
    );
  }
}
