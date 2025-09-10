import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myecommerceapp/data/models/favorite_model.dart';

class FavoriteRepository {
  final FirebaseFirestore _firestore;

  FavoriteRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get all favorites for user - FIXED VERSION
  Future<List<Favorite>> getFavorites(String userId) async {
    try {
      // Option 1: Simple query without orderBy (No index required)
      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      final favorites = snapshot.docs
          .map((doc) => Favorite.fromMap(doc.data()))
          .toList();

      // Sort in memory by addedAt descending
      favorites.sort((a, b) => b.addedAt.compareTo(a.addedAt));

      return favorites;
    } catch (e) {
      // ignore: avoid_print
      print('Error loading favorites: $e');
      return [];
    }
  }

  /// Alternative method with pagination support (if you need orderBy)
  Future<List<Favorite>> getFavoritesPaginated(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .limit(limit)
          .get();

      final favorites = snapshot.docs
          .map((doc) => Favorite.fromMap(doc.data()))
          .toList();

      // Sort in memory
      favorites.sort((a, b) => b.addedAt.compareTo(a.addedAt));

      return favorites;
    } catch (e) {
      // ignore: avoid_print
      print('Error loading favorites: $e');
      return [];
    }
  }

  /// Add to favorites
  Future<void> addToFavorites(String userId, String productId) async {
    try {
      final favoriteId = '${userId}_$productId';

      await _firestore.collection('favorites').doc(favoriteId).set({
        'id': favoriteId,
        'userId': userId,
        'productId': productId,
        'addedAt': FieldValue.serverTimestamp(), // Use server timestamp
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error adding to favorites: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  /// Remove from favorites
  Future<void> removeFromFavorites(String userId, String productId) async {
    try {
      final favoriteId = '${userId}_$productId';

      await _firestore.collection('favorites').doc(favoriteId).delete();
    } catch (e) {
      // ignore: avoid_print
      print('Error removing from favorites: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  /// Check if product is favorited
  Future<bool> isFavorite(String userId, String productId) async {
    try {
      final favoriteId = '${userId}_$productId';

      final doc = await _firestore
          .collection('favorites')
          .doc(favoriteId)
          .get();
      return doc.exists;
    } catch (e) {
      // ignore: avoid_print
      print('Error checking favorite status: $e');
      return false;
    }
  }

  /// Get favorites with real-time updates (Stream version)
  Stream<List<Favorite>> getFavoritesStream(String userId) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final favorites = snapshot.docs
              .map((doc) => Favorite.fromMap(doc.data()))
              .toList();

          // Sort in memory
          favorites.sort((a, b) => b.addedAt.compareTo(a.addedAt));

          return favorites;
        });
  }

  /// Batch operations for better performance
  Future<void> removeMultipleFavorites(
    String userId,
    List<String> productIds,
  ) async {
    try {
      final batch = _firestore.batch();

      for (String productId in productIds) {
        final favoriteId = '${userId}_$productId';
        final docRef = _firestore.collection('favorites').doc(favoriteId);
        batch.delete(docRef);
      }

      await batch.commit();
    } catch (e) {
      // ignore: avoid_print
      print('Error removing multiple favorites: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  /// Clear all favorites for user
  Future<void> clearAllFavorites(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      // ignore: avoid_print
      print('Error clearing favorites: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }
}
