import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/category.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ─── Products ─────────────────────────────────────────────────────────────
  Stream<List<Product>> productsStream() => _db
      .collection('products')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Product.fromFirestore).toList());

  Future<void> addProduct(Product p) =>
      _db.collection('products').add(p.toFirestore());

  Future<void> updateProduct(Product p) =>
      _db.collection('products').doc(p.id).update(p.toFirestore());

  Future<void> deleteProduct(String id) =>
      _db.collection('products').doc(id).delete();

  // ─── Orders ───────────────────────────────────────────────────────────────
  Stream<List<FishOrder>> ordersStream() => _db
      .collection('orders')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(FishOrder.fromFirestore).toList());

  Stream<List<FishOrder>> customerOrdersStream(String mobile) => _db
      .collection('orders')
      .where('customerMobile', isEqualTo: mobile)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(FishOrder.fromFirestore).toList());

  Future<String> placeOrder(FishOrder order) async {
    final ref = await _db.collection('orders').add(order.toFirestore());
    return ref.id;
  }

  Future<void> updateOrderStatus(String id, OrderStatus status) =>
      _db.collection('orders').doc(id).update({'status': status.name});

  Future<void> updateActualWeight(String id, double kg) async {
    final doc = await _db.collection('orders').doc(id).get();
    final order = FishOrder.fromFirestore(doc);
    final revised = (kg * (order.subtotal / (order.total - order.deliveryFee)))
            .clamp(0, double.infinity) +
        order.deliveryFee;
    await _db.collection('orders').doc(id).update({
      'actualWeight': kg,
      'revisedTotal': revised,
    });
  }

  Future<void> markCodCollected(String id, bool collected) =>
      _db.collection('orders').doc(id).update({'codCollected': collected});

  Future<void> deleteOrder(String id) =>
      _db.collection('orders').doc(id).delete();

  // ─── Categories ───────────────────────────────────────────────────────────
  Stream<List<FishCategory>> categoriesStream() => _db
      .collection('categories')
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map(FishCategory.fromFirestore).toList());

  Future<void> addCategory(FishCategory c) =>
      _db.collection('categories').add(c.toFirestore());

  Future<void> updateCategory(FishCategory c) =>
      _db.collection('categories').doc(c.id).update(c.toFirestore());

  Future<void> deleteCategory(String id) =>
      _db.collection('categories').doc(id).delete();

  // ─── Settings ─────────────────────────────────────────────────────────────
  Stream<Map<String, dynamic>> settingsStream() => _db
      .collection('settings')
      .doc('store')
      .snapshots()
      .map((s) => s.data() ?? {});

  Future<void> updateSettings(Map<String, dynamic> data) =>
      _db.collection('settings').doc('store').set(data, SetOptions(merge: true));
}
