import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myecommerceapp/core/theme/app_theme.dart';
import 'package:myecommerceapp/data/models/order_model.dart';
import 'package:myecommerceapp/providers/order_provider.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).loadUserOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(theme),
        body: Column(
          children: [
            _buildSearchAndFilter(theme),
            Expanded(child: _buildOrdersList()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor:
          theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      foregroundColor:
          theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface,
      title: Text(
        'My Orders',
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        Consumer(
          builder: (context, ref, child) {
            final orderState = ref.watch(orderProvider);

            return IconButton(
              onPressed: () {
                ref.read(orderProvider.notifier).refreshOrders();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Orders refreshed'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16.w),
                  ),
                );
              },
              icon: orderState.isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : Icon(Icons.refresh, color: theme.iconTheme.color),
            );
          },
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildSearchAndFilter(ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search orders',
          hintStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.hintColor,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.iconTheme.color,
            size: 20.w,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: Icon(
                    Icons.clear,
                    color: theme.iconTheme.color,
                    size: 20.w,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return Consumer(
      builder: (context, ref, child) {
        if (_searchQuery.isNotEmpty) {
          return ref
              .watch(searchOrdersProvider(_searchQuery))
              .when(
                data: (orders) => _buildOrdersListView(orders),
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(error.toString()),
              );
        }

        return ref
            .watch(userOrdersStreamProvider)
            .when(
              data: (orders) => _buildOrdersListView(orders),
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error.toString()),
            );
      },
    );
  }

  Widget _buildOrdersListView(List<Order> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(orderProvider.notifier).refreshOrders();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _getStatusColor(
                order.status,
              ).withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDate(order.orderDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                _buildStatusChip(order.status),
              ],
            ),
          ),

          // Order items preview
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 20.w,
                      color: theme.iconTheme.color,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${order.totalItems} items',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Items preview
                if (order.items.isNotEmpty)
                  ...order.items
                      .take(2)
                      .map(
                        (item) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: item.product.images.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        child: Image.network(
                                          item.product.images.first,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                                    Icons.image_not_supported,
                                                    color:
                                                        theme.iconTheme.color,
                                                    size: 20.w,
                                                  ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.image_not_supported,
                                        color: theme.iconTheme.color,
                                        size: 20.w,
                                      ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Qty: ${item.quantity}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontSize: 12.sp,
                                            color:
                                                theme.brightness ==
                                                    Brightness.dark
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                if (order.items.length > 2)
                  Text(
                    '+${order.items.length - 2} more items',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                SizedBox(height: 12.h),

                // Tracking number if available
                if (order.trackingNumber != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(
                        theme.brightness == Brightness.dark ? 0.2 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: 16.w,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Tracking: ${order.trackingNumber}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 16.h),

                // Action buttons
                Row(
                  children: [
                    if (order.canBeCancelled)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _cancelOrder(order.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      )
                    else if (order.isDelivered)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _reorder(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            'Reorder',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
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

  Widget _buildStatusChip(OrderStatus status) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _getStatusColor(
          status,
        ).withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.value,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.ordered:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.grey;
    }
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading orders...',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80.w,
            color: theme.iconTheme.color,
          ),
          SizedBox(height: 16.h),
          Text(
            'No orders found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start shopping to see your orders here',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[500]
                  : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              // Navigate to shop/home
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('Start Shopping', style: TextStyle(fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60.w,
            color: theme.brightness == Brightness.dark
                ? Colors.red[400]
                : Colors.red[400]!,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error loading orders',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: theme.brightness == Brightness.dark
                  ? Colors.red[400]
                  : Colors.red[400]!,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              ref.read(orderProvider.notifier).refreshOrders();
            },
            child: Text('Retry', style: TextStyle(fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  void _cancelOrder(String orderId) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text('Cancel Order', style: theme.textTheme.titleLarge),
        content: Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'No',
              style: TextStyle(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[800],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final success = await ref
                  .read(orderProvider.notifier)
                  .cancelOrder(orderId);

              if (success) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Order cancelled successfully'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16.w),
                  ),
                );
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Failed to cancel order'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16.w),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _reorder(Order order) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text('Reorder', style: theme.textTheme.titleLarge),
        content: Text(
          'Would you like to add these items to your cart again?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[800],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final orderId = await ref
                  .read(quickOrderActionsProvider)
                  .reorderFromExistingOrder(order);

              if (orderId != null) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Order placed successfully!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16.w),
                    action: SnackBarAction(
                      label: 'View',
                      textColor: Colors.white,
                      onPressed: () {
                        // Navigate to new order details
                      },
                    ),
                  ),
                );
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Failed to place reorder'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16.w),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Reorder'),
          ),
        ],
      ),
    );
  }
}
