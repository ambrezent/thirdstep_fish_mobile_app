import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import '../../providers/products_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/category_chip_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.navy,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.navy,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                                ),
                                child: const Center(child: Text('🐟', style: TextStyle(fontSize: 18))),
                              ),
                              const SizedBox(width: 10),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const Text('Third Step', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                                Text('Fish Trading', style: TextStyle(color: AppColors.gold.withValues(alpha: 0.8), fontSize: 10, letterSpacing: 0.5)),
                              ]),
                            ]),
                            GestureDetector(
                              onTap: () => showSearch(context: context, delegate: _FishSearchDelegate(ref)),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.search, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Fresh Catch,',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300, letterSpacing: -0.5, height: 1.1),
                        ),
                        Text(
                          'Delivered Fresh.',
                          style: TextStyle(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Container(
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
            ),
          ),

          // Categories
          const SliverToBoxAdapter(child: CategoryChipBar()),

          // Products grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: productsAsync.when(
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 1.5))),
              error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
              data: (products) {
                if (products.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('🐟', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text('No fish found', style: TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w400)),
                    ])),
                  );
                }
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => ProductCard(product: products[i], onTap: () => context.push('/product/${products[i].id}')),
                    childCount: products.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FishSearchDelegate extends SearchDelegate {
  final WidgetRef ref;
  _FishSearchDelegate(this.ref);

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context).copyWith(
        appBarTheme: const AppBarTheme(backgroundColor: AppColors.navy, foregroundColor: Colors.white),
        inputDecorationTheme: const InputDecorationTheme(hintStyle: TextStyle(color: Colors.white38)),
      );

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear, color: Colors.white), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final products = ref.read(productsStreamProvider).value ?? [];
    final q = query.toLowerCase();
    final filtered = products.where((p) => p.name.toLowerCase().contains(q) || p.nameAr.contains(q)).toList();

    if (filtered.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('🔍', style: TextStyle(fontSize: 40)),
        SizedBox(height: 12),
        Text('No results', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
      ]));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final p = filtered[i];
        return Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text('🐟', style: TextStyle(fontSize: 22))),
            ),
            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(p.nameAr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            trailing: Text('AED ${p.price.toStringAsFixed(0)}/kg', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.gold, fontSize: 13)),
            onTap: () { close(ctx, null); ctx.push('/product/${p.id}'); },
          ),
        );
      },
    );
  }
}
