import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myecommerceapp/data/models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _ordersCollection => _firestore.collection('orders');

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Create a new order
  Future<String> createOrder(Order order) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Generate order ID if not provided
      final orderId = order.id.isEmpty ? _ordersCollection.doc().id : order.id;

      // Create order with user ID and generated ID
      final orderWithIds = order.copyWith(
        id: orderId,
        userId: _currentUserId,
        orderDate: DateTime.now(),
        // Set estimated delivery to 5-7 business days
        estimatedDelivery: DateTime.now().add(const Duration(days: 7)),
      );

      // Save to Firestore
      await _ordersCollection.doc(orderId).set(orderWithIds.toMap());

      return orderId;
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  // Get all orders for current user
  Stream<List<Order>> getUserOrders() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _ordersCollection
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
        });
  }

  // Get specific order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();

      if (doc.exists) {
        final order = Order.fromMap(doc.data() as Map<String, dynamic>);

        // Verify user owns this order
        if (order.userId == _currentUserId) {
          return order;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get order: ${e.toString()}');
    }
  }

  // Get orders by status
  Stream<List<Order>> getOrdersByStatus(OrderStatus status) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _ordersCollection
        .where('userId', isEqualTo: _currentUserId)
        .where('status', isEqualTo: status.value)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
        });
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final updateData = <String, dynamic>{'status': status.value};

      // If delivered, add delivery date
      if (status == OrderStatus.delivered) {
        updateData['deliveredDate'] = DateTime.now().millisecondsSinceEpoch;
      }

      await _ordersCollection.doc(orderId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  // Cancel order (only if not shipped)
  Future<bool> cancelOrder(String orderId) async {
    try {
      // First get the order to check if it can be cancelled
      final order = await getOrderById(orderId);

      if (order == null) {
        throw Exception('Order not found');
      }

      if (!order.canBeCancelled) {
        return false; // Cannot cancel shipped/delivered orders
      }

      await updateOrderStatus(orderId, OrderStatus.cancelled);
      return true;
    } catch (e) {
      throw Exception('Failed to cancel order: ${e.toString()}');
    }
  }

  // Add tracking number
  Future<void> addTrackingNumber(String orderId, String trackingNumber) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'trackingNumber': trackingNumber,
        'status': OrderStatus.shipped.value,
      });
    } catch (e) {
      throw Exception('Failed to add tracking number: ${e.toString()}');
    }
  }

  // Get order statistics
  Future<Map<String, int>> getOrderStatistics() async {
    try {
      if (_currentUserId == null) {
        return {};
      }

      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: _currentUserId)
          .get();

      final stats = <String, int>{};

      for (final status in OrderStatus.values) {
        stats[status.value] = 0;
      }

      for (final doc in snapshot.docs) {
        final order = Order.fromMap(doc.data() as Map<String, dynamic>);
        stats[order.status.value] = (stats[order.status.value] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get order statistics: ${e.toString()}');
    }
  }

  // Search orders by product name or order ID
  Stream<List<Order>> searchOrders(String query) {
    if (_currentUserId == null || query.isEmpty) {
      return Stream.value([]);
    }

    return _ordersCollection
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          final allOrders = snapshot.docs
              .map((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          // Filter orders by query (order ID or product names)
          return allOrders.where((order) {
            final queryLower = query.toLowerCase();

            // Check order ID
            if (order.id.toLowerCase().contains(queryLower)) {
              return true;
            }

            // Check product names
            for (final item in order.items) {
              if (item.product.name.toLowerCase().contains(queryLower)) {
                return true;
              }
            }

            return false;
          }).toList();
        });
  }

  // Get recent orders (last 30 days)
  Stream<List<Order>> getRecentOrders() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    return _ordersCollection
        .where('userId', isEqualTo: _currentUserId)
        .where('orderDate', isGreaterThan: thirtyDaysAgo.millisecondsSinceEpoch)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
        });
  }

  // Delete order (admin only - for cleanup)
  Future<void> deleteOrder(String orderId) async {
    try {
      await _ordersCollection.doc(orderId).delete();
    } catch (e) {
      throw Exception('Failed to delete order: ${e.toString()}');
    }
  }

  // Batch update orders (for admin operations)
  Future<void> batchUpdateOrders(
    List<String> orderIds,
    Map<String, dynamic> updates,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final orderId in orderIds) {
        final docRef = _ordersCollection.doc(orderId);
        batch.update(docRef, updates);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update orders: ${e.toString()}');
    }
  }
}
