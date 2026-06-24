import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem item) {
    final idx = state.indexWhere(
      (e) => e.product.id == item.product.id && e.cut == item.cut,
    );
    if (idx >= 0) {
      final updated = List<CartItem>.from(state);
      updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + item.quantity);
      state = updated;
    } else {
      state = [...state, item];
    }
  }

  void updateQuantity(int index, double qty) {
    if (qty <= 0) return removeItem(index);
    final updated = List<CartItem>.from(state);
    updated[index] = updated[index].copyWith(quantity: qty);
    state = updated;
  }

  void removeItem(int index) {
    final updated = List<CartItem>.from(state)..removeAt(index);
    state = updated;
  }

  void clear() => state = [];

  double get subtotal => state.fold(0, (sum, item) => sum + item.subtotal);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (_) => CartNotifier(),
);

final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider.notifier).subtotal;
});
