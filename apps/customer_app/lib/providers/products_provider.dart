import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

final firestoreServiceProvider = Provider<FirestoreService>((_) => FirestoreService());

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(firestoreServiceProvider).productsStream();
});

final categoriesStreamProvider = StreamProvider<List<FishCategory>>((ref) {
  return ref.watch(firestoreServiceProvider).categoriesStream();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final products = ref.watch(productsStreamProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return products.whenData((list) => list.where((p) {
    final matchCat = category == null || p.category == category;
    final matchSearch = query.isEmpty ||
        p.name.toLowerCase().contains(query) ||
        p.nameAr.contains(query);
    return matchCat && matchSearch;
  }).toList());
});
