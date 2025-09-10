import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myecommerceapp/data/models/address_model.dart';
import 'package:myecommerceapp/data/repositories/address_repository.dart';

// Repository provider
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return LocalAddressRepository(); // Change to MockAddressRepository() for testing
});

// Address list state notifier
class AddressListNotifier extends StateNotifier<AsyncValue<List<Address>>> {
  AddressListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAddresses();
  }

  final AddressRepository _repository;

  Future<void> loadAddresses() async {
    state = const AsyncValue.loading();
    try {
      final addresses = await _repository.getAddresses();
      state = AsyncValue.data(addresses);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addAddress(Address address) async {
    try {
      await _repository.saveAddress(address);
      await loadAddresses(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateAddress(Address address) async {
    try {
      await _repository.updateAddress(address);
      await loadAddresses(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _repository.deleteAddress(id);
      await loadAddresses(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Address list provider
final addressListProvider =
    StateNotifierProvider<AddressListNotifier, AsyncValue<List<Address>>>((
      ref,
    ) {
      final repository = ref.watch(addressRepositoryProvider);
      return AddressListNotifier(repository);
    });

// Selected address provider for editing
final selectedAddressProvider = StateProvider<Address?>((ref) => null);

// Form state notifier for add/edit operations
class AddressFormNotifier extends StateNotifier<Address> {
  AddressFormNotifier() : super(Address.empty());

  void updateField({
    String? addressTitle,
    String? fullName,
    String? street,
    String? phone,
    String? city,
    String? stateValue,
  }) {
    state = state.copyWith(
      addressTitle: addressTitle,
      fullName: fullName,
      street: street,
      phone: phone,
      city: city,
      state: stateValue,
    );
  }

  void setAddress(Address address) {
    state = address;
  }

  void reset() {
    state = Address.empty();
  }

  bool get isValid {
    return state.addressTitle.isNotEmpty &&
        state.fullName.isNotEmpty &&
        state.street.isNotEmpty &&
        state.phone.isNotEmpty &&
        state.city.isNotEmpty &&
        state.state.isNotEmpty;
  }
}

// Form provider
final addressFormProvider = StateNotifierProvider<AddressFormNotifier, Address>(
  (ref) {
    return AddressFormNotifier();
  },
);

// Loading state provider for async operations
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Search/filter provider
final addressSearchProvider = StateProvider<String>((ref) => '');

// Filtered address list provider
final filteredAddressListProvider = Provider<AsyncValue<List<Address>>>((ref) {
  final addressListAsync = ref.watch(addressListProvider);
  final searchQuery = ref.watch(addressSearchProvider).toLowerCase();

  return addressListAsync.when(
    data: (addresses) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(addresses);
      }

      final filtered = addresses.where((address) {
        return address.addressTitle.toLowerCase().contains(searchQuery) ||
            address.fullName.toLowerCase().contains(searchQuery) ||
            address.street.toLowerCase().contains(searchQuery) ||
            address.city.toLowerCase().contains(searchQuery) ||
            address.state.toLowerCase().contains(searchQuery);
      }).toList();

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
