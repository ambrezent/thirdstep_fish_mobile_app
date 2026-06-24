import 'dart:math';

class OrderIdGenerator {
  static String generate() {
    final year = DateTime.now().year;
    final rand = Random().nextInt(9000) + 1000;
    return '#FT-$year-$rand';
  }
}
