import 'package:cloud_firestore/cloud_firestore.dart';

class Favorite {
  final String id;
  final String productId;
  final DateTime addedAt;

  Favorite({required this.id, required this.productId, required this.addedAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    // Handle both Timestamp and int for addedAt
    DateTime addedAt;
    if (map['addedAt'] is Timestamp) {
      addedAt = (map['addedAt'] as Timestamp).toDate();
    } else if (map['addedAt'] is int) {
      addedAt = DateTime.fromMillisecondsSinceEpoch(map['addedAt']);
    } else {
      addedAt = DateTime.now(); // Fallback
    }

    return Favorite(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      addedAt: addedAt,
    );
  }
}
