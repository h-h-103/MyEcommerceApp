import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myecommerceapp/data/models/product_model.dart';
import 'package:myecommerceapp/presentation/screens/main/tabs/cart.dart';
import 'package:myecommerceapp/providers/cart_provider.dart';
import 'package:myecommerceapp/providers/favorite_provider.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentImageIndex = 0;
  final List<String> _selectedSizes = [];
  final List<int> _selectedColorIndices =
      []; // Changed to List for multi-select
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(isDarkMode),
              _buildImageGallery(isDarkMode),
              _buildProductInfo(isDarkMode),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isDarkMode),
    );
  }

  Widget _buildAppBar(bool isDarkMode) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      foregroundColor: isDarkMode ? Colors.white : Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Cart icon with badge
        Consumer(
          builder: (context, ref, child) {
            final cartItemsAsync = ref.watch(cartItemsProvider);
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartTab()),
                  ),
                ),
                if (cartItemsAsync.asData?.value.isNotEmpty == true)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cartItemsAsync.asData!.value.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        // Updated Favorite Icon with Animation
        Consumer(
          builder: (context, ref, child) {
            // ignore: unused_local_variable
            final favoriteState = ref.watch(favoriteProvider);
            final isFavorite = ref
                .read(favoriteProvider.notifier)
                .isFavorite(widget.product.id);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: IconButton(
                onPressed: () => _toggleFavorite(ref),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(isFavorite),
                    color: isFavorite
                        ? Colors.red
                        : (isDarkMode ? Colors.white : Colors.black),
                    size: 24,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildImageGallery(bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Container(
        height: 0.4.sh,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1B1B1D) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main Image Carousel
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemCount: widget.product.images.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Image.network(
                    widget.product.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.image, size: 64.sp, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),

            // Offer Badge
            if (widget.product.offerPercentage != null)
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(15.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "-${widget.product.offerPercentage!.toStringAsFixed(0)}%",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Image Indicators
            if (widget.product.images.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.product.images.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      height: 8.h,
                      width: _currentImageIndex == index ? 24.w : 8.w,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == index
                            ? Colors.orange
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(bool isDarkMode) {
    return SliverPadding(
      padding: EdgeInsets.all(16.w),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Product Name & Category
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  widget.product.category,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Price Section
          _buildPriceSection(isDarkMode),

          SizedBox(height: 24.h),

          // Colors Section
          if (widget.product.colors?.isNotEmpty == true) ...[
            _buildColorSelector(isDarkMode),
            SizedBox(height: 24.h),
          ],

          // Sizes Section
          if (widget.product.sizes?.isNotEmpty == true) ...[
            _buildSizeSelector(isDarkMode),
            SizedBox(height: 24.h),
          ],

          // Quantity Section
          _buildQuantitySelector(isDarkMode),

          SizedBox(height: 24.h),

          // Description
          if (widget.product.description != null) ...[
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              widget.product.description!,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.6,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],

          SizedBox(height: 100.h), // Space for bottom bar
        ]),
      ),
    );
  }

  Widget _buildPriceSection(bool isDarkMode) {
    final originalPrice = widget.product.price;
    final discountedPrice = widget.product.offerPercentage != null
        ? originalPrice -
              (originalPrice * widget.product.offerPercentage! / 100)
        : originalPrice;

    return Row(
      children: [
        if (widget.product.offerPercentage != null) ...[
          Text(
            '\$${originalPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          SizedBox(width: 8.w),
        ],
        Text(
          '\$${discountedPrice.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Colors',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(width: 8.w),
            if (_selectedColorIndices.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${_selectedColorIndices.length} selected',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 50.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.product.colors!.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final color = Color(widget.product.colors![index]);
              final isSelected = _selectedColorIndices.contains(index);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedColorIndices.remove(index);
                    } else {
                      _selectedColorIndices.add(index);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.orange : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20.sp,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Sizes',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(width: 8.w),
            if (_selectedSizes.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${_selectedSizes.length} selected',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          children: widget.product.sizes!.map((size) {
            final isSelected = _selectedSizes.contains(size);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSizes.remove(size);
                  } else {
                    _selectedSizes.add(size);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.orange
                      : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      size,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
                    if (isSelected) ...[
                      SizedBox(width: 4.w),
                      Icon(Icons.check, size: 14.sp, color: Colors.white),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _buildQuantityButton(
              icon: Icons.remove,
              onTap: () {
                if (_quantity > 1) setState(() => _quantity--);
              },
              isDarkMode: isDarkMode,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '$_quantity',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            _buildQuantityButton(
              icon: Icons.add,
              onTap: () => setState(() => _quantity++),
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }

  Widget _buildBottomBar(bool isDarkMode) {
    final cartState = ref.watch(cartProvider);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Add to Cart Button
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: cartState.isLoading ? null : () => _addToCart(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: cartState.isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            SizedBox(width: 12.w),

            // Buy Now Button
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: cartState.isLoading ? null : () => _buyNow(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  side: const BorderSide(color: Colors.orange, width: 2),
                ),
                child: Text(
                  'Buy Now',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated _addToCart method with actual cart integration
  Future<void> _addToCart() async {
    if (!_validateSelections()) return;

    try {
      // Add to cart using the cart provider
      await ref
          .read(cartProvider.notifier)
          .addToCart(
            widget.product,
            quantity: _quantity,
            selectedColor: _selectedColorIndices.isNotEmpty
                ? widget.product.colors![_selectedColorIndices.first]
                : null,
            selectedSize: _selectedSizes.isNotEmpty
                ? _selectedSizes.first
                : null,
          );

      // Show success message
      String selectionSummary = _createSelectionSummary();

      if (mounted) {
        _showFeedback(
          'Added to cart successfully!',
          selectionSummary,
          Colors.green,
        );

        // Option 1: Show dialog asking user if they want to go to cart
        _showGoToCartDialog();

        // Option 2: Automatically navigate to cart (uncomment if preferred)
        // Future.delayed(const Duration(milliseconds: 500), () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => const CartScreen()),
        //   );
        // });
      }
    } catch (e) {
      if (mounted) {
        _showFeedback('Failed to add to cart', e.toString(), Colors.red);
      }
    }
  }

  void _showGoToCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Added to Cart'),
        content: Text('${widget.product.name} has been added to your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Shopping'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartTab()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text(
              'View Cart',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _buyNow() {
    if (!_validateSelections()) return;

    String selectionSummary = _createSelectionSummary();

    _showFeedback(
      'Proceeding to checkout: ${widget.product.name}',
      selectionSummary,
      Colors.orange,
    );
  }

  bool _validateSelections() {
    if (widget.product.colors?.isNotEmpty == true &&
        _selectedColorIndices.isEmpty) {
      _showSelectionError('Please select at least one color');
      return false;
    }

    if (widget.product.sizes?.isNotEmpty == true && _selectedSizes.isEmpty) {
      _showSelectionError('Please select at least one size');
      return false;
    }

    return true;
  }

  String _createSelectionSummary() {
    String selectionSummary = '';

    if (_selectedColorIndices.isNotEmpty) {
      selectionSummary += 'Colors: ${_selectedColorIndices.length} selected';
    }

    if (_selectedSizes.isNotEmpty) {
      if (selectionSummary.isNotEmpty) selectionSummary += ', ';
      selectionSummary += 'Sizes: ${_selectedSizes.join(', ')}';
    }

    if (selectionSummary.isNotEmpty) selectionSummary += ', ';
    selectionSummary += 'Quantity: $_quantity';

    return selectionSummary;
  }

  void _showFeedback(
    String message,
    String selectionSummary,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (selectionSummary.isNotEmpty)
              Text(selectionSummary, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: backgroundColor == Colors.green
            ? SnackBarAction(
                label: 'View Cart',
                textColor: Colors.white,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartTab()),
                ),
              )
            : null,
      ),
    );
  }

  void _showSelectionError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleFavorite(WidgetRef ref) {
    ref.read(favoriteProvider.notifier).toggleFavorite(widget.product);

    final isFavorite = ref
        .read(favoriteProvider.notifier)
        .isFavorite(widget.product.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isFavorite
                    ? '${widget.product.name} added to favorites!'
                    : '${widget.product.name} removed from favorites',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isFavorite ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        action: isFavorite
            ? SnackBarAction(
                label: 'View Favorites',
                textColor: Colors.white,
                onPressed: () {
                  // Navigate to favorites tab
                  DefaultTabController.of(
                    context,
                  ).animateTo(2); // Assuming favorites is tab index 2
                },
              )
            : null,
      ),
    );
  }
}
