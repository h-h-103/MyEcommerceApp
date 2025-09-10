import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myecommerceapp/core/theme/app_theme.dart';
import 'package:myecommerceapp/data/models/address_model.dart';
import 'package:myecommerceapp/data/models/cart_model.dart';
import 'package:myecommerceapp/data/models/order_model.dart';
import 'package:myecommerceapp/providers/cart_provider.dart';
import 'package:myecommerceapp/providers/order_provider.dart';

class CartTab extends ConsumerWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemsAsync = ref.watch(cartItemsProvider);
    // ignore: unused_local_variable
    final cartState = ref.watch(cartProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    // ignore: unused_local_variable
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Modern SliverAppBar
          SliverAppBar(
            expandedHeight: 120.h,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: isDarkMode
                ? const Color(0xFF1A1A1A)
                : Colors.white,
            foregroundColor: isDarkMode ? Colors.white : Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Shopping Cart',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              titlePadding: EdgeInsets.only(left: 20.w, bottom: 16.h),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)]
                        : [Colors.white, Colors.grey[100]!],
                  ),
                ),
              ),
            ),
            actions: [
              // Theme toggle button
              Container(
                margin: EdgeInsets.only(right: 8.w),
                child: IconButton(
                  onPressed: () =>
                      ref.read(themeProvider.notifier).toggleTheme(),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                  ),
                ),
              ),
              // Clear all button
              if (cartItemsAsync.asData?.value.isNotEmpty == true)
                Container(
                  margin: EdgeInsets.only(right: 16.w),
                  child: TextButton.icon(
                    onPressed: () => _showClearDialog(context, ref, isDarkMode),
                    icon: Icon(Icons.clear_all, size: 18.sp),
                    label: Text('Clear', style: TextStyle(fontSize: 14.sp)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.red.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Cart content
          cartItemsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return SliverToBoxAdapter(child: _buildEmptyCart(isDarkMode));
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == items.length) {
                    return SizedBox(height: 100.h); // Space for bottom bar
                  }
                  return CartItemCard(
                    item: items[index],
                    isDarkMode: isDarkMode,
                    onQuantityChanged: (quantity) {
                      ref
                          .read(cartProvider.notifier)
                          .updateQuantity(items[index].id, quantity);
                    },
                    onRemove: () {
                      ref
                          .read(cartProvider.notifier)
                          .removeFromCart(items[index].id);
                    },
                  );
                }, childCount: items.length + 1),
              );
            },
            loading: () => SliverToBoxAdapter(
              child: SizedBox(
                height: 0.5.sh,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Loading cart...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: SizedBox(
                height: 0.5.sh,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(
                        'Error loading cart',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDarkMode ? Colors.white70 : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(cartItemsProvider),
                        icon: Icon(Icons.refresh),
                        label: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.white
                              : Colors.black,
                          foregroundColor: isDarkMode
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: cartItemsAsync.when(
        data: (items) => items.isNotEmpty
            ? _buildBottomBar(context, ref, items, isDarkMode)
            : null,
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildEmptyCart(bool isDarkMode) {
    return SizedBox(
      height: 0.6.sh,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 60.sp,
                color: isDarkMode ? Colors.white54 : Colors.grey,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add some products to get started',
              style: TextStyle(
                fontSize: 16.sp,
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
            ),
            SizedBox(height: 32.h),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Colors.white, Colors.grey[300]!]
                      : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    List<CartItem> items,
    bool isDarkMode,
  ) {
    final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final totalItems = items.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total ($totalItems items)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Free Delivery',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Checkout button
            Container(
              width: double.infinity,
              height: 60.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Colors.white, Colors.grey[300]!]
                      : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? Colors.white : const Color(0xFF6366F1))
                        .withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () =>
                    _proceedToCheckout(context, ref, items, totalAmount),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      color: isDarkMode ? Colors.black : Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Clear Cart',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
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
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: TextButton(
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear All'),
            ),
          ),
        ],
      ),
    );
  }

  // Inside CartTab class, replace the _proceedToCheckout method with this:
  void _proceedToCheckout(
    BuildContext context,
    WidgetRef ref,
    List<CartItem> items,
    double totalAmount,
  ) {
    // 1. Navigate to Address Selection Screen
    // Pass cart items and total amount if needed on the address screen
    // Expect to receive the selected Address back
    Navigator.pushNamed(context, '/address').then((
      selectedAddressObject,
    ) async {
      // 4. Handle the result from the Address Screen
      if (selectedAddressObject != null && selectedAddressObject is Address) {
        final Address selectedAddress = selectedAddressObject;

        // 5. Navigate to the Order Confirmation/Review Screen
        // Pass the cart items, total amount, and selected address
        final confirmedOrder = await Navigator.pushNamed(
          // ignore: use_build_context_synchronously
          context,
          '/order', // Make sure you define this route
          arguments: {
            'cartItems': items,
            'totalAmount': totalAmount,
            'shippingAddress': selectedAddress,
          },
        );

        // 8. Handle the result from the Order Confirmation Screen
        if (confirmedOrder != null && confirmedOrder is Order) {
          try {
            // Show loading snackbar
            final snackBar = SnackBar(
              content: const Text('Placing order...'),
              // ignore: use_build_context_synchronously
              backgroundColor: Theme.of(context).primaryColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }

            // 9. Use the OrderRepository (or OrderNotifier) to save the confirmed order
            final orderRepository = ref.read(orderRepositoryProvider);
            final orderId = await orderRepository.createOrder(confirmedOrder);

            // Hide the processing snackbar
            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }

            if (context.mounted) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Order placed successfully! Order ID: ${orderId.substring(0, 8).toUpperCase()}',
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              );
              // Clear the cart after successful order placement
              ref.read(cartProvider.notifier).clearCart();

              // Navigate to the Orders Screen and clear the cart screen from the stack
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/order', // Ensure this route name matches your OrderScreen route
                  (route) => route.isFirst, // Removes all other routes
                );
              }
            } else {
              if (context.mounted) {
                // Show error message if order creation failed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Failed to place order. Please try again.',
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
              }
            }
          } catch (e) {
            // Hide the processing snackbar in case of error
            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              // Show generic error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('An error occurred: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              );
            }
          }
        } else {
          // User cancelled order confirmation
          // Optionally show a message or just do nothing
          // print("Order confirmation cancelled or failed.");
        }
      } else {
        // User cancelled address selection or didn't select an address
        // Optionally show a message or just do nothing
        if (context.mounted && selectedAddressObject != null) {
          // Check if it returned but wasn't an Address
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Invalid address selected. Please try again.',
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        }
        // If selectedAddressObject is null, it means back was pressed, so no snackbar needed.
      }
    });
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final bool isDarkMode;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.isDarkMode,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.25 : 0.07),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Product image
          Hero(
            tag: 'cart_${item.id}',
            child: Container(
              width: 75.w,
              height: 75.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: isDarkMode
                    ? Colors.white.withOpacity(0.08)
                    : Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  item.product.images.isNotEmpty
                      ? item.product.images.first
                      : '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image,
                    size: 28.sp,
                    color: isDarkMode ? Colors.white54 : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          /// Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Name
                Text(
                  item.product.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),

                /// Variants (size/color)
                if (item.selectedSize != null || item.selectedColor != null)
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: [
                      if (item.selectedSize != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.08)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Size: ${item.selectedSize}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      if (item.selectedColor != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.08)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 9.w,
                                height: 9.w,
                                decoration: BoxDecoration(
                                  color: Color(item.selectedColor!),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.white30
                                        : Colors.grey[400]!,
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Color',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                SizedBox(height: 8.h),

                /// Price + Quantity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Price
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),

                    /// Quantity Controls
                    Row(
                      children: [
                        _buildQuantityButton(Icons.remove, () {
                          if (item.quantity > 1) {
                            onQuantityChanged(item.quantity - 1);
                          }
                        }, isDarkMode),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.08)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '${item.quantity}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        _buildQuantityButton(
                          Icons.add,
                          () => onQuantityChanged(item.quantity + 1),
                          isDarkMode,
                        ),
                        SizedBox(width: 8.w),

                        /// Remove button
                        IconButton(
                          onPressed: onRemove,
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 18.sp,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
    IconData icon,
    VoidCallback onPressed,
    bool isDarkMode,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.grey[200],
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(
          icon,
          size: 14.sp,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
