import 'package:url_launcher/url_launcher.dart';
import '../models/order.dart';

class WhatsAppHelper {
  static const _waNumber = '971XXXXXXXXX'; // set from settings

  static String buildOrderMessage(FishOrder order) {
    final lines = <String>[
      '🐟 *Third Step Fish Trading*',
      '📋 Order: ${order.orderId}',
      '━━━━━━━━━━━━━━━━━━',
    ];

    for (final item in order.items) {
      final cutLabel = _cutLabel(item.cut);
      lines.add('• ${item.productName} (${item.productNameAr})');
      lines.add('  Cut: $cutLabel | Qty: ${item.quantity} kg');
      if (item.addons.isNotEmpty) lines.add('  Add-ons: ${item.addons.join(', ')}');
      if (item.notes.isNotEmpty) lines.add('  Notes: ${item.notes}');
    }

    lines.addAll([
      '━━━━━━━━━━━━━━━━━━',
      '👤 ${order.customerName}',
      '📱 ${order.customerMobile}',
      '📍 ${order.address}',
      if (order.geoPin != null) '🗺️ ${order.geoPin}',
      '🚚 ${order.deliveryType == DeliveryType.homeDelivery ? 'Home Delivery' : 'Shop Pickup'}',
      '🕐 ${order.deliveryWindow}',
      '━━━━━━━━━━━━━━━━━━',
      '💰 Subtotal: AED ${order.subtotal.toStringAsFixed(2)}',
      if (order.deliveryFee > 0) '🚚 Delivery: AED ${order.deliveryFee.toStringAsFixed(2)}',
      '💳 *Total: AED ${order.total.toStringAsFixed(2)}*',
      '💵 Payment: Cash on Delivery',
      '━━━━━━━━━━━━━━━━━━',
      '⚖️ _Final price may vary by actual weight_',
    ]);

    return lines.join('\n');
  }

  static Future<void> sendOrder(FishOrder order, {String? waNumber}) async {
    final number = waNumber ?? _waNumber;
    final message = Uri.encodeComponent(buildOrderMessage(order));
    final uri = Uri.parse('https://wa.me/$number?text=$message');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static String _cutLabel(FishCut cut) {
    switch (cut) {
      case FishCut.whole: return 'Whole';
      case FishCut.headOff: return 'Head-off';
      case FishCut.fillet: return 'Fillet';
      case FishCut.steaks: return 'Steaks';
      case FishCut.cubes: return 'Cubes';
      case FishCut.cleaned: return 'Cleaned';
    }
  }
}
