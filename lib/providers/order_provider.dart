import 'package:flutter/material.dart'; // Changed from dart:ui
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myecommerceapp/data/models/order_model.dart';
import 'package:myecommerceapp/data/models/cart_model.dart';
import 'package:myecommerceapp/data/models/address_model.dart';
import 'package:myecommerceapp/data/repositories/order_repository.dart';

// Repository provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

// Order state notifier
class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;

  OrderNotifier(this._repository) : super(const OrderState());

  // Create order from cart items
  Future<String?> createOrder({
    required List<CartItem> cartItems,
    required Address shippingAddress,
    required double totalAmount,
    required String paymentMethod,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final order = Order(
        id: '', // Will be generated in repository
        userId: '', // Will be set in repository
        items: cartItems,
        shippingAddress: shippingAddress,
        totalAmount: totalAmount,
        status: OrderStatus.ordered,
        orderDate: DateTime.now(),
        paymentMethod: paymentMethod,
        notes: notes,
      );

      final orderId = await _repository.createOrder(order);

      state = state.copyWith(isLoading: false);
      return orderId;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Load user orders
  void loadUserOrders() {
    state = state.copyWith(isLoading: true, error: null);

    _repository.getUserOrders().listen(
      (orders) {
        state = state.copyWith(orders: orders, isLoading: false, error: null);
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, error: error.toString());
      },
    );
  }

  // Get order by ID
  Future<void> getOrderById(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final order = await _repository.getOrderById(orderId);

      state = state.copyWith(selectedOrder: order, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      final success = await _repository.cancelOrder(orderId);

      if (success) {
        // Update local state
        final updatedOrders = state.orders.map((order) {
          if (order.id == orderId) {
            return order.copyWith(status: OrderStatus.cancelled);
          }
          return order;
        }).toList();

        state = state.copyWith(orders: updatedOrders);
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _repository.updateOrderStatus(orderId, status);

      // Update local state
      final updatedOrders = state.orders.map((order) {
        if (order.id == orderId) {
          var updatedOrder = order.copyWith(status: status);

          // Add delivery date if delivered
          if (status == OrderStatus.delivered) {
            updatedOrder = updatedOrder.copyWith(deliveredDate: DateTime.now());
          }

          return updatedOrder;
        }
        return order;
      }).toList();

      state = state.copyWith(orders: updatedOrders);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Clear selected order
  void clearSelectedOrder() {
    state = state.copyWith(selectedOrder: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh orders
  void refreshOrders() {
    loadUserOrders();
  }
}

// Order state provider
final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderNotifier(repository);
});

// Stream providers for different order states
final userOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getUserOrders();
});

final activeOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getUserOrders().map(
    (orders) => orders.where((order) => order.isActive).toList(),
  );
});

final deliveredOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getUserOrders().map(
    (orders) => orders.where((order) => order.isDelivered).toList(),
  );
});

// Orders by status provider
final ordersByStatusProvider = StreamProvider.family<List<Order>, OrderStatus>((
  ref,
  status,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrdersByStatus(status);
});

// Order statistics provider
final orderStatisticsProvider = FutureProvider<Map<String, int>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrderStatistics();
});

// Search orders provider
final searchOrdersProvider = StreamProvider.family<List<Order>, String>((
  ref,
  query,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.searchOrders(query);
});

// Recent orders provider (last 30 days)
final recentOrdersProvider = StreamProvider<List<Order>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getRecentOrders();
});

// Single order provider
final singleOrderProvider = FutureProvider.family<Order?, String>((
  ref,
  orderId,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrderById(orderId);
});

// Helper providers for UI
final hasActiveOrdersProvider = Provider<bool>((ref) {
  final orders = ref.watch(userOrdersStreamProvider);
  return orders.maybeWhen(
    data: (orderList) => orderList.any((order) => order.isActive),
    orElse: () => false,
  );
});

final totalOrdersCountProvider = Provider<int>((ref) {
  final orders = ref.watch(userOrdersStreamProvider);
  return orders.maybeWhen(
    data: (orderList) => orderList.length,
    orElse: () => 0,
  );
});

final deliveredOrdersCountProvider = Provider<int>((ref) {
  final orders = ref.watch(userOrdersStreamProvider);
  return orders.maybeWhen(
    data: (orderList) => orderList.where((order) => order.isDelivered).length,
    orElse: () => 0,
  );
});

// Quick actions provider for easy order operations
class QuickOrderActions {
  final OrderNotifier _notifier;
  // ignore: unused_field
  final OrderRepository _repository;

  QuickOrderActions(this._notifier, this._repository);

  // Create order and clear cart
  Future<String?> checkoutAndCreateOrder({
    required List<CartItem> cartItems,
    required Address shippingAddress,
    required double totalAmount,
    required String paymentMethod,
    String? notes,
    required VoidCallback onCartClear,
  }) async {
    final orderId = await _notifier.createOrder(
      cartItems: cartItems,
      shippingAddress: shippingAddress,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      notes: notes,
    );

    if (orderId != null) {
      // Clear cart after successful order creation
      onCartClear();
    }

    return orderId;
  }

  // Reorder (create new order from existing order)
  Future<String?> reorderFromExistingOrder(Order existingOrder) async {
    return await _notifier.createOrder(
      cartItems: existingOrder.items,
      shippingAddress: existingOrder.shippingAddress,
      totalAmount: existingOrder.totalAmount,
      paymentMethod: existingOrder.paymentMethod,
      notes: 'Reorder from #${existingOrder.id}',
    );
  }
}

final quickOrderActionsProvider = Provider<QuickOrderActions>((ref) {
  final notifier = ref.watch(orderProvider.notifier);
  final repository = ref.watch(orderRepositoryProvider);
  return QuickOrderActions(notifier, repository);
});
