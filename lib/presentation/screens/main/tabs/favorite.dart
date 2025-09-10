import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myecommerceapp/data/models/product_model.dart';
import 'package:myecommerceapp/presentation/screens/main/product_details.dart';
import 'package:myecommerceapp/providers/favorite_provider.dart';
import 'package:myecommerceapp/providers/cart_provider.dart';

class FavoriteTab extends ConsumerStatefulWidget {
  const FavoriteTab({super.key});

  @override
  ConsumerState<FavoriteTab> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends ConsumerState<FavoriteTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoriteProvider.notifier).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final favoriteState = ref.watch(favoriteProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (favoriteState.favoriteProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearAllDialog(),
            ),
        ],
      ),
      body: _buildBody(isDarkMode, favoriteState),
    );
  }

  Widget _buildBody(bool isDarkMode, FavoriteState favoriteState) {
    if (favoriteState.isLoading) {
      return _buildLoadingState();
    }

    if (favoriteState.error != null) {
      return _buildErrorState(favoriteState.error!, isDarkMode);
    }

    if (favoriteState.favoriteProducts.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return _buildFavoriteList(favoriteState, isDarkMode);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.orange),
          SizedBox(height: 16),
          Text('Loading your favorites...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              ref.read(favoriteProvider.notifier).clearError();
              ref.read(favoriteProvider.notifier).loadFavorites();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_outline,
              size: 64.sp,
              color: isDarkMode ? Colors.white54 : Colors.grey,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Start exploring and save your\nfavorite products here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey, height: 1.5),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildFavoriteList(FavoriteState favoriteState, bool isDarkMode) {
    final products = favoriteState.favoriteProducts;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(16.w),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${products.length} ${products.length == 1 ? 'Item' : 'Items'}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Row(
                  children: [
                    // Current sort indicator
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        ref
                            .read(favoriteProvider.notifier)
                            .getSortDisplayName(favoriteState.currentSort),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Sort button
                    TextButton.icon(
                      onPressed: () => _showSortOptions(),
                      icon: Icon(Icons.sort, size: 18.sp),
                      label: const Text('Sort'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];
              return _buildFavoriteItem(product, isDarkMode, index);
            }, childCount: products.length),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 20.h)),
      ],
    );
  }

  Widget _buildFavoriteItem(Product product, bool isDarkMode, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1B1B1D) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToProductDetails(product),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    product.images.isNotEmpty ? product.images.first : '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.image, color: Colors.grey, size: 32.sp),
                  ),
                ),
              ),

              SizedBox(width: 16.w),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        if (product.offerPercentage != null) ...[
                          Text(
                            '\$${product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(width: 4.w),
                        ],
                        Text(
                          '\$${(product.offerPercentage != null ? product.price - (product.price * product.offerPercentage! / 100) : product.price).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        if (product.offerPercentage != null) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '-${product.offerPercentage!.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 8.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  IconButton(
                    onPressed: () => _removeFromFavorites(product),
                    icon: Icon(Icons.favorite, color: Colors.red, size: 24.sp),
                  ),
                  IconButton(
                    onPressed: () => _showQuickActions(product),
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProductDetails(Product product) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailsPage(product: product),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _removeFromFavorites(Product product) {
    ref.read(favoriteProvider.notifier).toggleFavorite(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} removed from favorites'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () =>
              ref.read(favoriteProvider.notifier).toggleFavorite(product),
        ),
      ),
    );
  }

  void _showQuickActions(Product product) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1B1B1D) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),

            // Product info header
            Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      product.images.isNotEmpty ? product.images.first : '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.image, color: Colors.grey, size: 20.sp),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '\$${(product.offerPercentage != null ? product.price - (product.price * product.offerPercentage! / 100) : product.price).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Action buttons
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.orange,
                ),
              ),
              title: Text(
                'Add to Cart',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: const Text('Add this item to your cart'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _addToCart(product),
            ),

            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(Icons.share_outlined, color: Colors.blue),
              ),
              title: Text(
                'Share Product',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: const Text('Share with friends'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _shareProduct(product);
              },
            ),

            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(Icons.favorite_border, color: Colors.red),
              ),
              title: Text(
                'Remove from Favorites',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: const Text('Remove from your favorites'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _removeFromFavorites(product);
              },
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // Add to cart functionality with null safety improvements
  void _addToCart(Product product) async {
    Navigator.pop(context); // Close bottom sheet first

    try {
      // Check if product has variants (sizes/colors) with null safety
      final hasSizes = product.sizes?.isNotEmpty == true;
      final hasColors = product.colors?.isNotEmpty == true;

      if (hasSizes || hasColors) {
        await _showVariantSelectionDialog(product);
      } else {
        // Add directly to cart without variants
        await ref.read(cartProvider.notifier).addToCart(product, quantity: 1);
        _showSuccessSnackBar('${product.name} added to cart');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to add item to cart');
    }
  }

  // Show variant selection dialog with multi-select functionality
  Future<void> _showVariantSelectionDialog(Product product) async {
    // Initialize selected values with null safety
    List<String> selectedSizes = [];
    List<int> selectedColors = [];
    int quantity = 1;

    // Pre-select first available options if exists
    final availableSizes = product.sizes ?? [];
    final availableColors = product.colors ?? [];

    if (availableSizes.isNotEmpty) {
      selectedSizes.add(availableSizes.first);
    }
    if (availableColors.isNotEmpty) {
      selectedColors.add(availableColors.first);
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
            backgroundColor: isDarkMode
                ? const Color(0xFF1F1F1F)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Text(
              'Select Options',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product info
                  Row(
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            product.images.isNotEmpty
                                ? product.images.first
                                : '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '\$${(product.offerPercentage != null ? product.price - (product.price * product.offerPercentage! / 100) : product.price).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Multi-Size selection
                  if (availableSizes.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Size',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (selectedSizes.length ==
                                  availableSizes.length) {
                                selectedSizes.clear();
                              } else {
                                selectedSizes = List.from(availableSizes);
                              }
                            });
                          },
                          child: Text(
                            selectedSizes.length == availableSizes.length
                                ? 'Deselect All'
                                : 'Select All',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: availableSizes.map((size) {
                        final isSelected = selectedSizes.contains(size);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedSizes.remove(size);
                              } else {
                                selectedSizes.add(size);
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? Colors.orange : Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  Icon(
                                    Icons.check,
                                    size: 14.sp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4.w),
                                ],
                                Text(
                                  size,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : (isDarkMode
                                              ? Colors.white
                                              : Colors.black),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (selectedSizes.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Selected: ${selectedSizes.join(', ')}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 16.h),
                  ],

                  // Multi-Color selection
                  if (availableColors.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Color',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (selectedColors.length ==
                                  availableColors.length) {
                                selectedColors.clear();
                              } else {
                                selectedColors = List.from(availableColors);
                              }
                            });
                          },
                          child: Text(
                            selectedColors.length == availableColors.length
                                ? 'Deselect All'
                                : 'Select All',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: availableColors.map((colorValue) {
                        final isSelected = selectedColors.contains(colorValue);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedColors.remove(colorValue);
                              } else {
                                selectedColors.add(colorValue);
                              }
                            });
                          },
                          child: Container(
                            width: 45.w,
                            height: 45.w,
                            decoration: BoxDecoration(
                              color: Color(colorValue),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.orange : Colors.grey,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: _getContrastColor(Color(colorValue)),
                                    size: 16.sp,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    if (selectedColors.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Selected Colors: ',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: Wrap(
                                spacing: 4.w,
                                children: selectedColors.map((colorValue) {
                                  return Container(
                                    width: 16.w,
                                    height: 16.w,
                                    decoration: BoxDecoration(
                                      color: Color(colorValue),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 16.h),
                  ],

                  // Quantity selection
                  Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey[200],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => quantity++),
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey[200],
                        ),
                      ),
                    ],
                  ),

                  // Validation message
                  if ((availableSizes.isNotEmpty && selectedSizes.isEmpty) ||
                      (availableColors.isNotEmpty &&
                          selectedColors.isEmpty)) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Please select at least one option for each variant',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: isDarkMode
                      ? Colors.white70
                      : Colors.grey[600],
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    _canAddToCart(
                      availableSizes,
                      selectedSizes,
                      availableColors,
                      selectedColors,
                    )
                    ? () async {
                        Navigator.pop(context);
                        await _addToCartWithSelections(
                          product,
                          quantity,
                          selectedSizes,
                          selectedColors,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                  disabledForegroundColor: Colors.grey,
                ),
                child: const Text('Add to Cart'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper method to determine if user can add to cart
  bool _canAddToCart(
    List<String> availableSizes,
    List<String> selectedSizes,
    List<int> availableColors,
    List<int> selectedColors,
  ) {
    // If product has sizes, at least one must be selected
    if (availableSizes.isNotEmpty && selectedSizes.isEmpty) {
      return false;
    }

    // If product has colors, at least one must be selected
    if (availableColors.isNotEmpty && selectedColors.isEmpty) {
      return false;
    }

    return true;
  }

  // Helper method to get contrasting color for check icon
  Color _getContrastColor(Color backgroundColor) {
    // Calculate brightness
    final brightness =
        (backgroundColor.red * 299 +
            backgroundColor.green * 587 +
            backgroundColor.blue * 114) /
        1000;

    return brightness > 128 ? Colors.black : Colors.white;
  }

  // Add to cart with multiple selections
  Future<void> _addToCartWithSelections(
    Product product,
    int quantity,
    List<String> selectedSizes,
    List<int> selectedColors,
  ) async {
    try {
      // Generate all combinations of size and color
      List<Map<String, dynamic>> combinations = [];

      if (selectedSizes.isNotEmpty && selectedColors.isNotEmpty) {
        // Both sizes and colors selected - create combinations
        for (String size in selectedSizes) {
          for (int color in selectedColors) {
            combinations.add({
              'size': size,
              'color': color,
              'quantity': quantity,
            });
          }
        }
      } else if (selectedSizes.isNotEmpty) {
        // Only sizes selected
        for (String size in selectedSizes) {
          combinations.add({'size': size, 'color': null, 'quantity': quantity});
        }
      } else if (selectedColors.isNotEmpty) {
        // Only colors selected
        for (int color in selectedColors) {
          combinations.add({
            'size': null,
            'color': color,
            'quantity': quantity,
          });
        }
      } else {
        // No variants selected (shouldn't happen due to validation)
        combinations.add({'size': null, 'color': null, 'quantity': quantity});
      }

      // Add each combination to cart
      for (Map<String, dynamic> combination in combinations) {
        await ref
            .read(cartProvider.notifier)
            .addToCart(
              product,
              quantity: combination['quantity'],
              selectedSize: combination['size'],
              selectedColor: combination['color'],
            );
      }

      // Show success message with details
      String message = _buildSuccessMessage(product.name, combinations);
      _showSuccessSnackBar(message);
    } catch (e) {
      _showErrorSnackBar('Failed to add items to cart');
    }
  }

  // Helper method to build success message
  String _buildSuccessMessage(
    String productName,
    List<Map<String, dynamic>> combinations,
  ) {
    if (combinations.length == 1) {
      return '$productName added to cart';
    } else {
      return '$productName (${combinations.length} variants) added to cart';
    }
  }

  void _shareProduct(Product product) {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${product.name}...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to cart tab
            DefaultTabController.of(
              context,
            ).animateTo(2); // Assuming cart is at index 2
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSortOptions() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentSort = ref.read(favoriteProvider).currentSort;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1B1B1D) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Sort by',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 16.h),

            ...SortOption.values.map((option) {
              final isSelected = currentSort == option;
              final displayName = ref
                  .read(favoriteProvider.notifier)
                  .getSortDisplayName(option);
              IconData icon;

              switch (option) {
                case SortOption.recentlyAdded:
                  icon = Icons.access_time;
                  break;
                case SortOption.priceLowToHigh:
                  icon = Icons.arrow_upward;
                  break;
                case SortOption.priceHighToLow:
                  icon = Icons.arrow_downward;
                  break;
                case SortOption.nameAtoZ:
                  icon = Icons.sort_by_alpha;
                  break;
                case SortOption.nameZtoA:
                  icon = Icons.sort_by_alpha;
                  break;
              }

              return ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.orange
                        : (isDarkMode ? Colors.white70 : Colors.grey[600]),
                  ),
                ),
                title: Text(
                  displayName,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Colors.orange
                        : (isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.orange)
                    : null,
                onTap: () {
                  ref.read(favoriteProvider.notifier).sortProducts(option);
                  Navigator.pop(context);
                },
              );
            }),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Clear All Favorites',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all products from your favorites? This action cannot be undone.',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.white70 : Colors.grey[600],
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(favoriteProvider.notifier).clearAllFavorites();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All favorites cleared'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
