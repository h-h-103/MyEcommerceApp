import 'package:myecommerceapp/data/models/cart_model.dart';
import 'package:myecommerceapp/data/models/address_model.dart';

enum OrderStatus {
  ordered('Ordered'),
  confirmed('Confirmed'),
  shipped('Shipped'),
  delivered('Delivered'),
  cancelled('Cancelled'),
  returned('Returned');

  const OrderStatus(this.value);
  final String value;

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'ordered':
        return OrderStatus.ordered;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'returned':
        return OrderStatus.returned;
      default:
        return OrderStatus.ordered;
    }
  }
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final Address shippingAddress;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredDate;
  final String? trackingNumber;
  final String paymentMethod;
  final String? notes;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.estimatedDelivery,
    this.deliveredDate,
    this.trackingNumber,
    required this.paymentMethod,
    this.notes,
  });

  // Empty constructor
  Order.empty()
    : id = '',
      userId = '',
      items = const [],
      shippingAddress = Address.empty(),
      totalAmount = 0.0,
      status = OrderStatus.ordered,
      orderDate = DateTime.now(),
      estimatedDelivery = null,
      deliveredDate = null,
      trackingNumber = null,
      paymentMethod = '',
      notes = null;

  // Copy with method
  Order copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    Address? shippingAddress,
    double? totalAmount,
    OrderStatus? status,
    DateTime? orderDate,
    DateTime? estimatedDelivery,
    DateTime? deliveredDate,
    String? trackingNumber,
    String? paymentMethod,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }

  // Getters
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get canBeCancelled =>
      status == OrderStatus.ordered || status == OrderStatus.confirmed;

  bool get isDelivered => status == OrderStatus.delivered;

  bool get isActive =>
      status != OrderStatus.cancelled &&
      status != OrderStatus.delivered &&
      status != OrderStatus.returned;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'shippingAddress': shippingAddress.toJson(),
      'totalAmount': totalAmount,
      'status': status.value,
      'orderDate': orderDate.millisecondsSinceEpoch,
      'estimatedDelivery': estimatedDelivery?.millisecondsSinceEpoch,
      'deliveredDate': deliveredDate?.millisecondsSinceEpoch,
      'trackingNumber': trackingNumber,
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }

  // Create from Firestore document
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: map['items'] != null
          ? List<CartItem>.from(
              map['items'].map((item) => CartItem.fromMap(item)),
            )
          : [],
      shippingAddress: Address.fromJson(map['shippingAddress'] ?? {}),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.fromString(map['status'] ?? 'ordered'),
      orderDate: map['orderDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['orderDate'])
          : DateTime.now(),
      estimatedDelivery: map['estimatedDelivery'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['estimatedDelivery'])
          : null,
      deliveredDate: map['deliveredDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deliveredDate'])
          : null,
      trackingNumber: map['trackingNumber'],
      paymentMethod: map['paymentMethod'] ?? '',
      notes: map['notes'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Order(id: $id, userId: $userId, totalAmount: $totalAmount, status: $status, orderDate: $orderDate)';
  }
}

// Order state for managing UI state
class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final Order? selectedOrder;

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.selectedOrder,
  });

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    Order? selectedOrder,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedOrder: selectedOrder ?? this.selectedOrder,
    );
  }

  // Get orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return orders.where((order) => order.status == status).toList();
  }

  // Get active orders
  List<Order> get activeOrders {
    return orders.where((order) => order.isActive).toList();
  }

  // Get delivered orders
  List<Order> get deliveredOrders {
    return orders.where((order) => order.isDelivered).toList();
  }
}
