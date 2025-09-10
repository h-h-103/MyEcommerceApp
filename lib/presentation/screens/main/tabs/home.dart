import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myecommerceapp/core/theme/app_theme.dart';
import 'package:myecommerceapp/data/models/product_model.dart';
import 'package:myecommerceapp/presentation/screens/main/product_details.dart';
import 'package:myecommerceapp/providers/product_provider.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    Future.microtask(() {
      ref.read(productProvider.notifier).fetchAllProducts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(productProvider.notifier).fetchAllProducts();
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(isDarkMode),

              /// Animated Search Box
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: _showSearch
                      ? _buildSearchSection(isDarkMode)
                      : const SizedBox.shrink(),
                ),
              ),

              _buildCategoryChips(selectedCategory, isDarkMode),

              if (productState.isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),

              if (productState.error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 48.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Something went wrong",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (!productState.isLoading &&
                  productState.error == null &&
                  productState.products.isNotEmpty)
                _buildProductsGrid(productState.products, isDarkMode),

              if (!productState.isLoading &&
                  productState.error == null &&
                  productState.products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48.sp,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "No products found",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDarkMode) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      foregroundColor: isDarkMode ? Colors.white : Colors.black,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'ShopApp',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      actions: [
        // Search Button
        IconButton(
          icon: Icon(_showSearch ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
                ref.read(productProvider.notifier).fetchAllProducts();
              }
            });
          },
        ),

        // Dark/Light Mode Toggle
        IconButton(
          onPressed: () {
            ref.read(themeProvider.notifier).toggleTheme();
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: child.key == const ValueKey("dark")
                  ? Tween<double>(begin: 1, end: 0.75).animate(anim)
                  : Tween<double>(begin: 0.75, end: 1).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              isDarkMode ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDarkMode ? "light" : "dark"),
            ),
          ),
        ),

        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchSection(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 16.sp,
        ),
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (query) {
          ref.read(searchQueryProvider.notifier).state = query;
          if (query.isEmpty) {
            ref.read(productProvider.notifier).fetchAllProducts();
          } else {
            ref.read(productProvider.notifier).searchProducts(query);
          }
        },
      ),
    );
  }

  Widget _buildCategoryChips(String? selectedCategory, bool isDarkMode) {
    final categories = [
      "All",
      "Electronics",
      "Clothing",
      "Books",
      "Beauty & Health",
      "Automotive",
      "Other",
    ];

    return SliverToBoxAdapter(
      child: Container(
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected =
                selectedCategory == category ||
                (category == "All" && selectedCategory == null);

            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) {
                if (category == "All") {
                  ref.read(selectedCategoryProvider.notifier).state = null;
                  ref.read(productProvider.notifier).fetchAllProducts();
                } else {
                  ref.read(selectedCategoryProvider.notifier).state = category;
                  ref
                      .read(productProvider.notifier)
                      .fetchProductsByCategory(category);
                }
              },
              backgroundColor: isDarkMode
                  ? const Color(0xFF2A2A2A)
                  : Colors.grey[200],
              selectedColor: isDarkMode
                  ? const Color(0xFF3A3A3A)
                  : Colors.orange,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.black87),
                fontSize: 14.sp,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductsGrid(List<Product> products, bool isDarkMode) {
    return SliverPadding(
      padding: EdgeInsets.all(12.w),
      sliver: SliverGrid.builder(
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final product = products[index];

          /// Fade + Slide Animation
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _buildProductCard(product, isDarkMode),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        // Navigate to product details page with smooth animation
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProductDetailsPage(product: product),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1B1B1D) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==== Product Image with Offer Badge ====
            Stack(
              children: [
                Hero(
                  tag:
                      'product-image-${product.id}', // Add unique hero tag for smooth transition
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18.r),
                    ),
                    child: Image.network(
                      product.images.isNotEmpty ? product.images.first : "",
                      height: 0.18.sh,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 0.18.sh,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image,
                          size: 36.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                if (product.offerPercentage != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        "-${product.offerPercentage!.toStringAsFixed(0)}%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ==== Product Details ====
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Category
                    Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 6.h),

                    // ==== Colors + Sizes Row ====
                    if ((product.colors?.isNotEmpty ?? false) ||
                        (product.sizes?.isNotEmpty ?? false))
                      Row(
                        children: [
                          // Colors preview
                          if (product.colors != null &&
                              product.colors!.isNotEmpty)
                            SizedBox(
                              height: 22.w,
                              child: ListView.separated(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: product.colors!.length > 3
                                    ? 3
                                    : product.colors!.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: 4.w),
                                itemBuilder: (context, index) {
                                  final color = Color(product.colors![index]);
                                  return Container(
                                    width: 18.w,
                                    height: 18.w,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          SizedBox(width: 8.w),

                          // Sizes preview
                          if (product.sizes != null &&
                              product.sizes!.isNotEmpty)
                            Expanded(
                              child: SizedBox(
                                height: 22.h,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: product.sizes!.length > 3
                                      ? 3
                                      : product.sizes!.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(width: 4.w),
                                  itemBuilder: (context, index) {
                                    final size = product.sizes![index];
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                      ),
                                      child: Text(
                                        size,
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),

                    SizedBox(height: 10.h),

                    // ==== Price Row ====
                    Row(
                      children: [
                        if (product.offerPercentage != null)
                          Flexible(
                            child: FittedBox(
                              child: Text(
                                "\$${product.price.toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: FittedBox(
                            child: Text(
                              "\$${product.offerPercentage == null ? product.price : (product.price - (product.price * product.offerPercentage! / 100)).toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
