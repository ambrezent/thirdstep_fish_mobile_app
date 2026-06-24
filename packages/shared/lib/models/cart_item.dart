import 'product.dart';

class CartItem {
  final Product product;
  final FishCut cut;
  final double quantity;
  final List<String> addons;
  final String notes;

  const CartItem({
    required this.product,
    required this.cut,
    required this.quantity,
    required this.addons,
    required this.notes,
  });

  double get subtotal => quantity * product.price;

  CartItem copyWith({
    FishCut? cut,
    double? quantity,
    List<String>? addons,
    String? notes,
  }) =>
      CartItem(
        product: product,
        cut: cut ?? this.cut,
        quantity: quantity ?? this.quantity,
        addons: addons ?? this.addons,
        notes: notes ?? this.notes,
      );
}
