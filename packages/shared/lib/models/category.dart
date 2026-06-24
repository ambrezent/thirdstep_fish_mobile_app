import 'package:cloud_firestore/cloud_firestore.dart';

class FishCategory {
  final String id;
  final String name;
  final String nameAr;
  final String slug;
  final String color;
  final DateTime createdAt;

  const FishCategory({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
    required this.color,
    required this.createdAt,
  });

  factory FishCategory.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FishCategory(
      id: doc.id,
      name: d['name'] ?? '',
      nameAr: d['nameAr'] ?? '',
      slug: d['slug'] ?? '',
      color: d['color'] ?? '#1a3a5c',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'nameAr': nameAr,
        'slug': slug,
        'color': color,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
