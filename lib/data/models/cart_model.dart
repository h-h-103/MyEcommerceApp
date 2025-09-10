import 'package:myecommerceapp/data/models/product_model.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final int? selectedColor;
  final String? selectedSize;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedColor,
    this.selectedSize,
    required this.addedAt,
  });

  CartItem.empty()
    : id = '',
      product = Product.empty(),
      quantity = 0,
      selectedColor = null,
      selectedSize = null,
      addedAt = DateTime.now();

  double get totalPrice {
    double price = product.price;
    if (product.offerPercentage != null) {
      price = price * (1 - product.offerPercentage! / 100);
    }
    return price * quantity;
  }

  String get uniqueKey =>
      '${product.id}_${selectedColor ?? 'noColor'}_${selectedSize ?? 'noSize'}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': product.id,
      'product': product.toMap(),
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      product: Product.fromMap(map['product'] ?? {}),
      quantity: map['quantity'] ?? 0,
      selectedColor: map['selectedColor'],
      selectedSize: map['selectedSize'],
      addedAt: map['addedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['addedAt'])
          : DateTime.now(),
    );
  }

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    int? selectedColor,
    String? selectedSize,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  CartState({this.items = const [], this.isLoading = false, this.error});

  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({List<CartItem>? items, bool? isLoading, String? error}) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
