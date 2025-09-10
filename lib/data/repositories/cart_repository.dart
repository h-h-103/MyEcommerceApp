import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myecommerceapp/data/models/cart_model.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _cartRef =>
      _firestore.collection('users').doc(_userId).collection('cart');

  // Add item to cart
  Future<void> addToCart(CartItem item) async {
    if (_userId == null) throw Exception('User not authenticated');

    final existingQuery = await _cartRef
        .where('productId', isEqualTo: item.product.id)
        .where('selectedColor', isEqualTo: item.selectedColor)
        .where('selectedSize', isEqualTo: item.selectedSize)
        .get();

    if (existingQuery.docs.isNotEmpty) {
      // Update existing item
      final doc = existingQuery.docs.first;
      final existingItem = CartItem.fromMap(doc.data() as Map<String, dynamic>);
      await doc.reference.update({
        'quantity': existingItem.quantity + item.quantity,
      });
    } else {
      // Add new item
      await _cartRef.doc(item.id).set(item.toMap());
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String itemId) async {
    if (_userId == null) throw Exception('User not authenticated');
    await _cartRef.doc(itemId).delete();
  }

  // Update item quantity
  Future<void> updateQuantity(String itemId, int quantity) async {
    if (_userId == null) throw Exception('User not authenticated');
    if (quantity <= 0) {
      await removeFromCart(itemId);
    } else {
      await _cartRef.doc(itemId).update({'quantity': quantity});
    }
  }

  // Get cart items
  Stream<List<CartItem>> getCartItems() {
    if (_userId == null) return Stream.value([]);

    return _cartRef
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CartItem.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  // Clear cart
  Future<void> clearCart() async {
    if (_userId == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    final cartItems = await _cartRef.get();

    for (final doc in cartItems.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Get cart count
  Future<int> getCartCount() async {
    if (_userId == null) return 0;

    final snapshot = await _cartRef.get();
    int totalCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalCount += (data['quantity'] as int? ?? 0);
    }

    return totalCount;
  }
}
