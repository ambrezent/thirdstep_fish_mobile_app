import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

enum OrderStatus { pending, confirmed, preparing, outForDelivery, delivered, cancelled }

enum DeliveryType { homeDelivery, shopPickup }

enum PaymentMethod { whatsappCod, onlinePayment }

enum OrderSource { app, whatsapp }

class OrderItem {
  final String productId;
  final String productName;
  final String productNameAr;
  final FishCut cut;
  final double quantity;
  final double pricePerKg;
  final List<String> addons;
  final String notes;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.productNameAr,
    required this.cut,
    required this.quantity,
    required this.pricePerKg,
    required this.addons,
    required this.notes,
  });

  double get subtotal => quantity * pricePerKg;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'productNameAr': productNameAr,
        'cut': cut.name,
        'quantity': quantity,
        'pricePerKg': pricePerKg,
        'addons': addons,
        'notes': notes,
      };

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        productId: m['productId'] ?? '',
        productName: m['productName'] ?? '',
        productNameAr: m['productNameAr'] ?? '',
        cut: FishCut.values.firstWhere(
          (f) => f.name == m['cut'],
          orElse: () => FishCut.whole,
        ),
        quantity: (m['quantity'] ?? 1).toDouble(),
        pricePerKg: (m['pricePerKg'] ?? 0).toDouble(),
        addons: List<String>.from(m['addons'] ?? []),
        notes: m['notes'] ?? '',
      );
}

class FishOrder {
  final String id;
  final String orderId; // #FT-YYYY-XXXX
  final String customerName;
  final String customerMobile;
  final String address;
  final String? geoPin;
  final List<OrderItem> items;
  final DeliveryType deliveryType;
  final String deliveryWindow;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final double? actualWeight;
  final double? revisedTotal;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final OrderSource source;
  final bool codCollected;
  final DateTime createdAt;

  const FishOrder({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.customerMobile,
    required this.address,
    this.geoPin,
    required this.items,
    required this.deliveryType,
    required this.deliveryWindow,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.actualWeight,
    this.revisedTotal,
    required this.status,
    required this.paymentMethod,
    required this.source,
    required this.codCollected,
    required this.createdAt,
  });

  factory FishOrder.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FishOrder(
      id: doc.id,
      orderId: d['orderId'] ?? '',
      customerName: d['customerName'] ?? '',
      customerMobile: d['customerMobile'] ?? '',
      address: d['address'] ?? '',
      geoPin: d['geoPin'],
      items: ((d['items'] as List?) ?? [])
          .map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
          .toList(),
      deliveryType: DeliveryType.values.firstWhere(
        (t) => t.name == d['deliveryType'],
        orElse: () => DeliveryType.homeDelivery,
      ),
      deliveryWindow: d['deliveryWindow'] ?? '',
      subtotal: (d['subtotal'] ?? 0).toDouble(),
      deliveryFee: (d['deliveryFee'] ?? 0).toDouble(),
      total: (d['total'] ?? 0).toDouble(),
      actualWeight: d['actualWeight']?.toDouble(),
      revisedTotal: d['revisedTotal']?.toDouble(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == d['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (p) => p.name == d['paymentMethod'],
        orElse: () => PaymentMethod.whatsappCod,
      ),
      source: OrderSource.values.firstWhere(
        (s) => s.name == d['source'],
        orElse: () => OrderSource.app,
      ),
      codCollected: d['codCollected'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'orderId': orderId,
        'customerName': customerName,
        'customerMobile': customerMobile,
        'address': address,
        'geoPin': geoPin,
        'items': items.map((i) => i.toMap()).toList(),
        'deliveryType': deliveryType.name,
        'deliveryWindow': deliveryWindow,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': total,
        'actualWeight': actualWeight,
        'revisedTotal': revisedTotal,
        'status': status.name,
        'paymentMethod': paymentMethod.name,
        'source': source.name,
        'codCollected': codCollected,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  double get displayTotal => revisedTotal ?? total;

  bool get isCod => paymentMethod == PaymentMethod.whatsappCod;
}
