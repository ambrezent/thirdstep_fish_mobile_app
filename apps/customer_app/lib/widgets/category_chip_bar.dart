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
  const CategoryChipBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final selected = ref.watch(selectedCategoryProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox(height: 56),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) => SizedBox(
        height: 56,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          children: [
            _Chip(emoji: '🌊', label: 'All', selected: selected == null, onTap: () => ref.read(selectedCategoryProvider.notifier).state = null),
            ...categories.map((c) => _Chip(
                  emoji: _categoryEmojis[c.slug] ?? '🐟',
                  label: c.name,
                  selected: selected == c.slug,
                  onTap: () => ref.read(selectedCategoryProvider.notifier).state = c.slug,
                )),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String emoji, label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.emoji, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.navy : AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: TextStyle(fontSize: selected ? 13 : 12)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? Colors.white : AppColors.textSecondary,
              letterSpacing: 0.1,
            ),
          ),
        ]),
      ),
    );
  }
}
