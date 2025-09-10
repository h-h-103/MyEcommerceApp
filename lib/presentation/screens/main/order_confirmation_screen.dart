import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myecommerceapp/core/theme/app_theme.dart';
import 'package:myecommerceapp/data/models/cart_model.dart';
import 'package:myecommerceapp/data/models/address_model.dart';
import 'package:myecommerceapp/data/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderConfirmationScreen extends ConsumerStatefulWidget {
  static const routeName = '/order';

  const OrderConfirmationScreen({super.key});

  @override
  ConsumerState<OrderConfirmationScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderConfirmationScreen>
    with TickerProviderStateMixin {
  late List<CartItem> cartItems;
  late double totalAmount;
  late Address shippingAddress;
  String paymentMethod = 'Cash on Delivery';

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    cartItems = args?['cartItems'] as List<CartItem>? ?? [];
    totalAmount = args?['totalAmount'] as double? ?? 0.0;
    shippingAddress = args?['shippingAddress'] as Address? ?? Address.empty();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFAFAFA),
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(isDarkMode),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // _buildProgressIndicator(isDarkMode),
                            SizedBox(height: 24.h),
                            _buildModernOrderSummaryCard(isDarkMode),
                            SizedBox(height: 20.h),
                            _buildModernShippingAddressCard(isDarkMode),
                            SizedBox(height: 20.h),
                            _buildModernOrderItemsList(isDarkMode),
                            SizedBox(height: 20.h),
                            _buildModernPaymentMethodCard(isDarkMode),
                            SizedBox(height: 20.h),
                            _buildModernTotalSummary(isDarkMode),
                            SizedBox(height: 100.h), // Space for button
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildModernConfirmButton(isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: (isDarkMode ? Colors.black : Colors.white).withOpacity(0.9),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'Order Confirmation',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            color: isDarkMode ? Colors.white : Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ),
      leading: Container(
        margin: EdgeInsets.only(left: 16.w),
        child: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: (isDarkMode ? Colors.black : Colors.white).withOpacity(
                0.9,
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: (isDarkMode ? Colors.white : Colors.black).withOpacity(
                  0.1,
                ),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18.sp,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  // Widget _buildProgressIndicator(bool isDarkMode) {
  //   return Container(
  //     padding: EdgeInsets.all(20.w),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           Theme.of(context).primaryColor.withOpacity(0.1),
  //           Theme.of(context).primaryColor.withOpacity(0.05),
  //         ],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(20.r),
  //       border: Border.all(
  //         color: Theme.of(context).primaryColor.withOpacity(0.2),
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: EdgeInsets.all(12.w),
  //           decoration: BoxDecoration(
  //             color: Theme.of(context).primaryColor,
  //             borderRadius: BorderRadius.circular(12.r),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Theme.of(context).primaryColor.withOpacity(0.3),
  //                 blurRadius: 8,
  //                 offset: const Offset(0, 4),
  //               ),
  //             ],
  //           ),
  //           child: Icon(
  //             Icons.shopping_bag_outlined,
  //             color: Colors.white,
  //             size: 24.sp,
  //           ),
  //         ),
  //         SizedBox(width: 16.w),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Review Your Order',
  //                 style: TextStyle(
  //                   fontSize: 18.sp,
  //                   fontWeight: FontWeight.bold,
  //                   color: isDarkMode ? Colors.white : Colors.black,
  //                 ),
  //               ),
  //               SizedBox(height: 4.h),
  //               Text(
  //                 'Please review all details before placing your order',
  //                 style: TextStyle(
  //                   fontSize: 14.sp,
  //                   color: isDarkMode ? Colors.white70 : Colors.black54,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildModernOrderSummaryCard(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: const Color(0xFF007AFF),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: (isDarkMode ? Colors.white : Colors.black).withOpacity(
                0.03,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                _buildModernInfoRow(
                  'Order Date',
                  DateFormat('MMM dd, yyyy • HH:mm').format(DateTime.now()),
                  Icons.calendar_today_outlined,
                  isDarkMode,
                ),
                SizedBox(height: 12.h),
                _buildModernInfoRow(
                  'Total Items',
                  '${cartItems.fold(0, (sum, item) => sum + item.quantity)} items',
                  Icons.shopping_cart_outlined,
                  isDarkMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernShippingAddressCard(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: const Color(0xFF34C759),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: (isDarkMode ? Colors.white : Colors.black).withOpacity(
                0.03,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFF34C759).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shippingAddress.fullName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 16.sp,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${shippingAddress.street} ${shippingAddress.city} ${shippingAddress.state}',
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black87,
                              height: 1.4,
                            ),
                          ),
                          // Text(
                          //   '${shippingAddress.city}, ${shippingAddress.state}',
                          //   style: TextStyle(
                          //     fontSize: 15.sp,
                          //     color: isDarkMode
                          //         ? Colors.white70
                          //         : Colors.black87,
                          //     height: 1.4,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 16.sp,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      shippingAddress.phone,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
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

  Widget _buildModernOrderItemsList(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: const Color(0xFFFF9500),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${cartItems.fold(0, (sum, item) => sum + item.quantity)} items',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF9500),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartItems.length,
            separatorBuilder: (context, index) => Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: (isDarkMode ? Colors.white : Colors.black).withOpacity(
                    0.03,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: (isDarkMode ? Colors.white : Colors.black)
                              .withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.r),
                        child: Image.network(
                          item.product.images.isNotEmpty
                              ? item.product.images.first
                              : '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: isDarkMode
                                ? Colors.white12
                                : Colors.grey[100],
                            child: Icon(
                              Icons.image_outlined,
                              color: isDarkMode ? Colors.white54 : Colors.grey,
                              size: 28.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.selectedSize != null ||
                              item.selectedColor != null)
                            Padding(
                              padding: EdgeInsets.only(top: 6.h),
                              child: Row(
                                children: [
                                  if (item.selectedSize != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (isDarkMode
                                                    ? Colors.white
                                                    : Colors.black)
                                                .withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Text(
                                        item.selectedSize!,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  if (item.selectedSize != null &&
                                      item.selectedColor != null)
                                    SizedBox(width: 8.w),
                                  if (item.selectedColor != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (isDarkMode
                                                    ? Colors.white
                                                    : Colors.black)
                                                .withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Text(
                                        'Color',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  'Qty: ${item.quantity}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              Text(
                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModernPaymentMethodCard(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF5856D6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.payment_outlined,
                  color: const Color(0xFF5856D6),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF5856D6).withOpacity(0.1),
                  const Color(0xFF5856D6).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFF5856D6).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5856D6),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5856D6).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMethod,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5856D6),
                      ),
                    ),
                    Text(
                      'Payment on delivery',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: (isDarkMode ? Colors.white : Colors.black)
                            .withOpacity(0.6),
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

  Widget _buildModernTotalSummary(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: [
      //       Theme.of(context).primaryColor.withOpacity(0.03),
      //       Theme.of(context).primaryColor.withOpacity(0.01),
      //     ],
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      //   borderRadius: BorderRadius.circular(24.r),
      //   border: Border.all(
      //     color: Theme.of(context).primaryColor.withOpacity(0.2),
      //   ),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Theme.of(context).primaryColor.withOpacity(0.1),
      //       blurRadius: 20,
      //       offset: const Offset(0, 8),
      //     ),
      //   ],
      // ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.receipt_outlined,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Order Total',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: (isDarkMode ? Colors.white : Colors.black).withOpacity(
                0.03,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                _buildModernInfoRow(
                  'Subtotal',
                  '\$${totalAmount.toStringAsFixed(2)}',
                  Icons.receipt_long_outlined,
                  isDarkMode,
                ),
                SizedBox(height: 12.h),
                _buildModernInfoRow(
                  'Delivery',
                  'Free',
                  Icons.local_shipping_outlined,
                  isDarkMode,
                  valueColor: const Color(0xFF34C759),
                ),
                SizedBox(height: 16.h),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Theme.of(context).primaryColor.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  Widget _buildModernInfoRow(
    String label,
    String value,
    IconData icon,
    bool isDarkMode, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: isDarkMode ? Colors.white60 : Colors.black54,
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: valueColor ?? (isDarkMode ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildModernConfirmButton(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        border: Border(
          top: BorderSide(
            color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.08),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: (isDarkMode ? Colors.white : Colors.black).withOpacity(
                0.2,
              ),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
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
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                flex: 2,
                child: Container(
                  height: 56.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.r),
                      onTap: _confirmOrder,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Place Order',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'By placing this order, you agree to our terms and conditions',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDarkMode ? Colors.white54 : Colors.black45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _confirmOrder() {
    final order = Order(
      id: '',
      userId: '',
      items: cartItems,
      shippingAddress: shippingAddress,
      totalAmount: totalAmount,
      status: OrderStatus.ordered,
      orderDate: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(days: 7)),
      deliveredDate: null,
      trackingNumber: null,
      paymentMethod: paymentMethod,
      notes: '',
    );

    Navigator.pop(context, order);
  }
}
