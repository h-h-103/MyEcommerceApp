import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myecommerceapp/data/models/product_model.dart';
import 'package:myecommerceapp/data/models/favorite_model.dart';
import 'package:myecommerceapp/data/repositories/favorite_repository.dart';
import 'package:myecommerceapp/data/repositories/product_repository.dart';
import 'package:myecommerceapp/providers/product_provider.dart';

/// Provider for favorite repository
final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository();
});

/// Enum for sort options
enum SortOption {
  recentlyAdded,
  priceLowToHigh,
  priceHighToLow,
  nameAtoZ,
  nameZtoA,
}

/// State for favorites with sorting
class FavoriteState {
  final List<Product> favoriteProducts;
  final Set<String> favoriteProductIds;
  final bool isLoading;
  final String? error;
  final SortOption currentSort;

  const FavoriteState({
    this.favoriteProducts = const [],
    this.favoriteProductIds = const {},
    this.isLoading = false,
    this.error,
    this.currentSort = SortOption.recentlyAdded,
  });

  FavoriteState copyWith({
    List<Product>? favoriteProducts,
    Set<String>? favoriteProductIds,
    bool? isLoading,
    String? error,
    SortOption? currentSort,
  }) {
    return FavoriteState(
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentSort: currentSort ?? this.currentSort,
    );
  }
}

/// Updated Notifier with sorting functionality
class FavoriteNotifier extends StateNotifier<FavoriteState> {
  final FavoriteRepository _favoriteRepository;
  final ProductRepository _productRepository;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // Store the original list with favorites data for sorting
  List<Favorite> _originalFavorites = [];

  FavoriteNotifier(this._favoriteRepository, this._productRepository)
    : super(const FavoriteState());

  /// Load favorites with better error handling
  Future<void> loadFavorites() async {
    if (state.isLoading) return; // Prevent multiple simultaneous loads

    state = state.copyWith(isLoading: true, error: null);

    try {
      final favorites = await _favoriteRepository.getFavorites(userId);
      _originalFavorites = favorites; // Store original data
      final productIds = favorites.map((f) => f.productId).toSet();

      if (productIds.isNotEmpty) {
        // Get products for favorites
        final allProducts = await _productRepository.getAllProducts();
        final favoriteProducts = allProducts
            .where((product) => productIds.contains(product.id))
            .toList();

        // Sort the products based on current sort option
        final sortedProducts = _sortProducts(
          favoriteProducts,
          state.currentSort,
        );

        state = state.copyWith(
          favoriteProducts: sortedProducts,
          favoriteProductIds: productIds,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          favoriteProducts: [],
          favoriteProductIds: {},
          isLoading: false,
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading favorites: $e');
      state = state.copyWith(
        error: 'Failed to load favorites. Please try again.',
        isLoading: false,
      );
    }
  }

  /// Sort products based on selected option
  void sortProducts(SortOption sortOption) {
    final sortedProducts = _sortProducts(state.favoriteProducts, sortOption);

    state = state.copyWith(
      favoriteProducts: sortedProducts,
      currentSort: sortOption,
    );
  }

  /// Private method to handle actual sorting logic
  List<Product> _sortProducts(List<Product> products, SortOption sortOption) {
    final productsCopy = List<Product>.from(products);

    switch (sortOption) {
      case SortOption.recentlyAdded:
        // Sort by the order they were added to favorites (use original favorites order)
        productsCopy.sort((a, b) {
          final aFavorite = _originalFavorites.firstWhere(
            (fav) => fav.productId == a.id,
            orElse: () =>
                Favorite(id: '', productId: '', addedAt: DateTime.now()),
          );
          final bFavorite = _originalFavorites.firstWhere(
            (fav) => fav.productId == b.id,
            orElse: () =>
                Favorite(id: '', productId: '', addedAt: DateTime.now()),
          );
          return bFavorite.addedAt.compareTo(
            aFavorite.addedAt,
          ); // Most recent first
        });
        break;

      case SortOption.priceLowToHigh:
        productsCopy.sort((a, b) {
          final aPrice = a.offerPercentage != null
              ? a.price - (a.price * a.offerPercentage! / 100)
              : a.price;
          final bPrice = b.offerPercentage != null
              ? b.price - (b.price * b.offerPercentage! / 100)
              : b.price;
          return aPrice.compareTo(bPrice);
        });
        break;

      case SortOption.priceHighToLow:
        productsCopy.sort((a, b) {
          final aPrice = a.offerPercentage != null
              ? a.price - (a.price * a.offerPercentage! / 100)
              : a.price;
          final bPrice = b.offerPercentage != null
              ? b.price - (b.price * b.offerPercentage! / 100)
              : b.price;
          return bPrice.compareTo(aPrice);
        });
        break;

      case SortOption.nameAtoZ:
        productsCopy.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;

      case SortOption.nameZtoA:
        productsCopy.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
    }

    return productsCopy;
  }

  /// Get sort option display name
  String getSortDisplayName(SortOption option) {
    switch (option) {
      case SortOption.recentlyAdded:
        return 'Recently Added';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.nameAtoZ:
        return 'Name: A to Z';
      case SortOption.nameZtoA:
        return 'Name: Z to A';
    }
  }

  /// Toggle favorite with optimistic updates
  Future<void> toggleFavorite(Product product) async {
    final isFavorite = state.favoriteProductIds.contains(product.id);

    // Optimistic update
    if (isFavorite) {
      final updatedIds = Set<String>.from(state.favoriteProductIds)
        ..remove(product.id);
      final updatedProducts = state.favoriteProducts
          .where((p) => p.id != product.id)
          .toList();

      state = state.copyWith(
        favoriteProductIds: updatedIds,
        favoriteProducts: updatedProducts,
      );
    } else {
      final updatedIds = Set<String>.from(state.favoriteProductIds)
        ..add(product.id);
      final updatedProducts = [...state.favoriteProducts, product];

      // Sort the new list according to current sort option
      final sortedProducts = _sortProducts(updatedProducts, state.currentSort);

      state = state.copyWith(
        favoriteProductIds: updatedIds,
        favoriteProducts: sortedProducts,
      );
    }

    try {
      // Perform the actual database operation
      if (isFavorite) {
        await _favoriteRepository.removeFromFavorites(userId, product.id);
        // Remove from original favorites list
        _originalFavorites.removeWhere((fav) => fav.productId == product.id);
      } else {
        await _favoriteRepository.addToFavorites(userId, product.id);
        // Add to original favorites list
        _originalFavorites.add(
          Favorite(
            id: '${userId}_${product.id}',
            productId: product.id,
            addedAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      // Revert optimistic update on error
      if (isFavorite) {
        final revertIds = Set<String>.from(state.favoriteProductIds)
          ..add(product.id);
        final revertProducts = [...state.favoriteProducts, product];

        state = state.copyWith(
          favoriteProductIds: revertIds,
          favoriteProducts: revertProducts,
          error: 'Failed to remove from favorites',
        );
      } else {
        final revertIds = Set<String>.from(state.favoriteProductIds)
          ..remove(product.id);
        final revertProducts = state.favoriteProducts
            .where((p) => p.id != product.id)
            .toList();

        state = state.copyWith(
          favoriteProductIds: revertIds,
          favoriteProducts: revertProducts,
          error: 'Failed to add to favorites',
        );
      }
    }
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      await _favoriteRepository.clearAllFavorites(userId);
      _originalFavorites.clear();

      state = state.copyWith(favoriteProducts: [], favoriteProductIds: {});
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear favorites');
    }
  }

  /// Check if product is favorite
  bool isFavorite(String productId) {
    return state.favoriteProductIds.contains(productId);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for favorite notifier
final favoriteProvider = StateNotifierProvider<FavoriteNotifier, FavoriteState>(
  (ref) {
    final favoriteRepo = ref.watch(favoriteRepositoryProvider);
    final productRepo = ref.watch(productRepositoryProvider);
    return FavoriteNotifier(favoriteRepo, productRepo);
  },
);
