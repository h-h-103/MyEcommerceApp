import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myecommerceapp/core/theme/app_theme.dart';
import 'package:myecommerceapp/data/models/address_model.dart';
import 'package:myecommerceapp/providers/address_provider.dart';

class AddressScreen extends ConsumerWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressListAsync = ref.watch(filteredAddressListProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(
          'Addresses',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.sp),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80.h),
          child: Container(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SearchBar(
              onChanged: (value) {
                ref.read(addressSearchProvider.notifier).state = value;
              },
              hintText: 'Search addresses...',
              hintStyle: MaterialStateProperty.all(
                TextStyle(color: theme.hintColor, fontSize: 14.sp),
              ),
              backgroundColor: MaterialStateProperty.all(
                isDarkMode ? const Color(0xFF1F1F1F) : Colors.grey[100],
              ),
              elevation: MaterialStateProperty.all(0),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(horizontal: 16.w),
              ),
              leading: Icon(Icons.search, color: theme.hintColor, size: 20.sp),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ),
      ),
      body: addressListAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            color: theme.colorScheme.primary,
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: Colors.red[300]),
                SizedBox(height: 16.h),
                Text(
                  'Error loading addresses',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  error.toString(),
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(addressListProvider.notifier).loadAddresses(),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (addresses) => addresses.isEmpty
            ? const EmptyAddressView()
            : ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return AddressCard(
                    address: address,
                    onEdit: () => _showAddEditDialog(context, ref, address),
                    onDelete: () => _showDeleteDialog(context, ref, address),
                    onTap: () {
                      // When the card is tapped, pop and return the selected address
                      Navigator.pop(context, address);
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, ref, null),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add, size: 20.sp),
        label: Text(
          'Add Address',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }

  void _showAddEditDialog(
    BuildContext context,
    WidgetRef ref,
    Address? address,
  ) {
    if (address != null) {
      ref.read(addressFormProvider.notifier).setAddress(address);
    } else {
      ref.read(addressFormProvider.notifier).reset();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => AddEditAddressSheet(isEditing: address != null),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Address address) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete Address',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${address.addressTitle}"?',
          style: TextStyle(
            fontSize: 14.sp,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(addressListProvider.notifier).deleteAddress(address.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Address deleted successfully'),
                  backgroundColor: theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}

class EmptyAddressView extends ConsumerWidget {
  const EmptyAddressView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 80.sp,
              color: theme.hintColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Addresses Yet',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.headlineSmall?.color,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add your first address to get started',
              style: TextStyle(
                fontSize: 16.sp,
                color: theme.textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AddressCard extends ConsumerWidget {
  final Address address;
  final VoidCallback onEdit; // For editing the address
  final VoidCallback onDelete; // For deleting the address
  final VoidCallback?
  onTap; // NEW: Callback for when the card is tapped/selected

  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    this.onTap, // Accept the onTap callback
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(isDarkModeProvider);

    // Wrap the Card's child in an InkWell or GestureDetector to make it tappable
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: isDarkMode ? 4 : 2,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
      // Use InkWell for Material ripple effect, or GestureDetector if you prefer
      child: InkWell(
        onTap: onTap, // Assign the onTap callback here
        borderRadius: BorderRadius.circular(16.r), // Match card border radius
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      address.addressTitle,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: IconButton(
                          onPressed: onEdit, // Keep existing edit functionality
                          icon: Icon(Icons.edit_outlined, size: 18.sp),
                          color: theme.colorScheme.primary,
                          padding: EdgeInsets.all(8.w),
                          constraints: BoxConstraints(
                            minWidth: 36.w,
                            minHeight: 36.h,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: IconButton(
                          onPressed:
                              onDelete, // Keep existing delete functionality
                          icon: Icon(Icons.delete_outline, size: 18.sp),
                          color: Colors.red[400],
                          padding: EdgeInsets.all(8.w),
                          constraints: BoxConstraints(
                            minWidth: 36.w,
                            minHeight: 36.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildInfoRow(Icons.person_outline, address.fullName, theme),
              SizedBox(height: 8.h),
              _buildInfoRow(
                Icons.location_on_outlined,
                '${address.street}, ${address.city}, ${address.state}',
                theme,
              ),
              SizedBox(height: 8.h),
              _buildInfoRow(Icons.phone_outlined, address.phone, theme),
            ],
          ),
        ),
      ),
    );
  }

  // ... (rest of the AddressCard code like _buildInfoRow remains the same)
  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: theme.hintColor),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }
}

class AddEditAddressSheet extends ConsumerStatefulWidget {
  final bool isEditing;

  const AddEditAddressSheet({super.key, required this.isEditing});

  @override
  ConsumerState<AddEditAddressSheet> createState() =>
      _AddEditAddressSheetState();
}

class _AddEditAddressSheetState extends ConsumerState<AddEditAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  final _addressTitleController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _streetController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final address = ref.read(addressFormProvider);
      if (widget.isEditing) {
        _addressTitleController.text = address.addressTitle;
        _fullNameController.text = address.fullName;
        _streetController.text = address.street;
        _phoneController.text = address.phone;
        _cityController.text = address.city;
        _stateController.text = address.state;
      }
    });
  }

  @override
  void dispose() {
    _addressTitleController.dispose();
    _fullNameController.dispose();
    _streetController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: theme.hintColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.isEditing
                                    ? 'Edit Address'
                                    : 'Add New Address',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.titleLarge?.color,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                size: 24.sp,
                                color: theme.iconTheme.color,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: theme.hintColor.withOpacity(
                                  0.1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        _buildTextField(
                          controller: _addressTitleController,
                          label: 'Address Title',
                          hint: 'Home, Office, etc.',
                          icon: Icons.label_outline,
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          hint: 'Enter full name',
                          icon: Icons.person_outline,
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _streetController,
                          label: 'Street Address',
                          hint: 'Enter street address',
                          icon: Icons.location_on_outlined,
                          maxLines: 2,
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _cityController,
                                label: 'City',
                                hint: 'Enter city',
                                icon: Icons.location_city_outlined,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _buildTextField(
                                controller: _stateController,
                                label: 'State',
                                hint: 'Enter state',
                                icon: Icons.map_outlined,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: 'Enter phone number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 32.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _saveAddress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 20.h,
                                    width: 20.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : Text(
                                    widget.isEditing
                                        ? 'Update Address'
                                        : 'Save Address',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        // Add extra padding for keyboard
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 14.sp,
        color: theme.textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(fontSize: 14.sp, color: theme.hintColor),
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: theme.hintColor.withOpacity(0.7),
        ),
        prefixIcon: Icon(icon, color: theme.hintColor, size: 20.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(isLoadingProvider.notifier).state = true;

    try {
      final currentAddress = ref.read(addressFormProvider);
      final address = Address(
        id: widget.isEditing ? currentAddress.id : '',
        addressTitle: _addressTitleController.text.trim(),
        fullName: _fullNameController.text.trim(),
        street: _streetController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
      );

      if (widget.isEditing) {
        await ref.read(addressListProvider.notifier).updateAddress(address);
      } else {
        await ref.read(addressListProvider.notifier).addAddress(address);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Address updated successfully'
                  : 'Address added successfully',
              style: TextStyle(fontSize: 14.sp),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: TextStyle(fontSize: 14.sp),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }
}
