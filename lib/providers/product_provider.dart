import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myecommerceapp/data/models/product_model.dart';
import 'package:myecommerceapp/data/repositories/product_repository.dart';

/// Provider for repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

/// State for product list
class ProductState {
  final List<Product> products;
  final bool isLoading;
  final String? error;

  const ProductState({
    this.products = const [],
    this.isLoading = false,
    this.error,
  });

  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for products
class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository _repository;
  ProductNotifier(this._repository) : super(const ProductState());

  /// Get all products
  Future<void> fetchAllProducts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _repository.getAllProducts();
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Get products by category
  Future<void> fetchProductsByCategory(String category) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _repository.getProductsByCategory(category);
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Search by name
  Future<void> searchProducts(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _repository.searchProductsByName(query);
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

/// Provider for notifier
final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((
  ref,
) {
  final repo = ref.watch(productRepositoryProvider);
  return ProductNotifier(repo);
});

/// Search query provider (used in HomeTab)
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Selected category provider
final selectedCategoryProvider = StateProvider<String?>((ref) => null);
