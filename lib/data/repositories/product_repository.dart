import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myecommerceapp/data/models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get all products
  Future<List<Product>> getAllProducts() async {
    final snapshot = await _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    final snapshot = await _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
  }

  /// Search products by name (case insensitive)
  Future<List<Product>> searchProductsByName(String query) async {
    final snapshot = await _firestore
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '$query\uf8ff')
        .get();

    return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
  }
}
