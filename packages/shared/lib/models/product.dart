import 'package:cloud_firestore/cloud_firestore.dart';

enum FishCut { whole, headOff, fillet, steaks, cubes, cleaned }

enum StockBadge { inStock, lowStock, outOfStock, bestSeller, preOrder }

class Product {
  final String id;
  final String name;
  final String nameAr;
  final String family;
  final String category;
  final double price;
  final String unit;
  final int stockQty;
  final double grossWeight;
  final double netYield;
  final StockBadge badge;
  final String imageUrl;
  final bool preOrder;
  final List<FishCut> cuts;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.family,
    required this.category,
    required this.price,
    required this.unit,
    required this.stockQty,
    required this.grossWeight,
    required this.netYield,
    required this.badge,
    required this.imageUrl,
    required this.preOrder,
    required this.cuts,
    required this.createdAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      nameAr: data['nameAr'] ?? '',
      family: data['family'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'kg',
      stockQty: data['stockQty'] ?? 0,
      grossWeight: (data['grossWeight'] ?? 0).toDouble(),
      netYield: (data['netYield'] ?? 0).toDouble(),
      badge: StockBadge.values.firstWhere(
        (b) => b.name == data['badge'],
        orElse: () => StockBadge.inStock,
      ),
      imageUrl: data['imageUrl'] ?? '',
      preOrder: data['preOrder'] ?? false,
      cuts: ((data['cuts'] as List?) ?? [])
          .map((c) => FishCut.values.firstWhere(
                (f) => f.name == c,
                orElse: () => FishCut.whole,
              ))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'nameAr': nameAr,
        'family': family,
        'category': category,
        'price': price,
        'unit': unit,
        'stockQty': stockQty,
        'grossWeight': grossWeight,
        'netYield': netYield,
        'badge': badge.name,
        'imageUrl': imageUrl,
        'preOrder': preOrder,
        'cuts': cuts.map((c) => c.name).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
      };

  bool get isAvailable => stockQty > 0 || preOrder;
}
