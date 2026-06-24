import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

final firestoreServiceProvider = Provider<FirestoreService>((_) => FirestoreService());

final ordersStreamProvider = StreamProvider<List<FishOrder>>((ref) {
  return ref.watch(firestoreServiceProvider).ordersStream();
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(firestoreServiceProvider).productsStream();
});

final categoriesStreamProvider = StreamProvider<List<FishCategory>>((ref) {
  return ref.watch(firestoreServiceProvider).categoriesStream();
});

final settingsStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(firestoreServiceProvider).settingsStream();
});

// Derived stats
final pendingOrdersProvider = Provider<AsyncValue<List<FishOrder>>>((ref) {
  return ref.watch(ordersStreamProvider).whenData(
    (orders) => orders.where((o) => o.status == OrderStatus.pending).toList(),
  );
});

final totalRevenueProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(ordersStreamProvider).whenData(
    (orders) => orders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (sum, o) => sum + o.displayTotal),
  );
});

final orderSourceFilterProvider = StateProvider<OrderSource?>((ref) => null);

final filteredOrdersProvider = Provider<AsyncValue<List<FishOrder>>>((ref) {
  final source = ref.watch(orderSourceFilterProvider);
  return ref.watch(ordersStreamProvider).whenData(
    (orders) => source == null ? orders : orders.where((o) => o.source == source).toList(),
  );
});
