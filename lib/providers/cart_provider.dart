import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myecommerceapp/data/models/cart_model.dart';
import 'package:myecommerceapp/data/models/product_model.dart';
import 'package:myecommerceapp/data/repositories/cart_repository.dart';

// Cart repository provider
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository();
});

// Cart state provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final repository = ref.read(cartRepositoryProvider);
  return CartNotifier(repository);
});

// Cart items stream provider
final cartItemsProvider = StreamProvider<List<CartItem>>((ref) {
  final repository = ref.read(cartRepositoryProvider);
  return repository.getCartItems();
});

// Cart count provider
final cartCountProvider = FutureProvider<int>((ref) {
  final repository = ref.read(cartRepositoryProvider);
  return repository.getCartCount();
});

class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _repository;

  CartNotifier(this._repository) : super(CartState()) {
    _loadCartItems();
  }

  void _loadCartItems() {
    state = state.copyWith(isLoading: true, error: null);

    _repository.getCartItems().listen(
      (items) {
        state = state.copyWith(items: items, isLoading: false, error: null);
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, error: error.toString());
      },
    );
  }

  Future<void> addToCart(
    Product product, {
    int quantity = 1,
    int? selectedColor,
    String? selectedSize,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final cartItem = CartItem(
        id: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        quantity: quantity,
        selectedColor: selectedColor,
        selectedSize: selectedSize,
        addedAt: DateTime.now(),
      );

      await _repository.addToCart(cartItem);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.removeFromCart(itemId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      await _repository.updateQuantity(itemId, quantity);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.clearCart();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
