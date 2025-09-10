import 'dart:convert';
import 'package:myecommerceapp/data/models/address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AddressRepository {
  Future<List<Address>> getAddresses();
  Future<void> saveAddress(Address address);
  Future<void> updateAddress(Address address);
  Future<void> deleteAddress(String id);
  Future<Address?> getAddressById(String id);
}

class LocalAddressRepository implements AddressRepository {
  static const String _storageKey = 'addresses';

  @override
  Future<List<Address>> getAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? addressesJson = prefs.getString(_storageKey);

      if (addressesJson == null) {
        return [];
      }

      final List<dynamic> addressesList = json.decode(addressesJson);
      return addressesList
          .map((json) => Address.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load addresses: $e');
    }
  }

  @override
  Future<void> saveAddress(Address address) async {
    try {
      final addresses = await getAddresses();

      // Generate ID if not provided
      final newAddress = address.id.isEmpty
          ? address.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
            )
          : address;

      addresses.add(newAddress);
      await _saveAddresses(addresses);
    } catch (e) {
      throw Exception('Failed to save address: $e');
    }
  }

  @override
  Future<void> updateAddress(Address address) async {
    try {
      final addresses = await getAddresses();
      final index = addresses.indexWhere((a) => a.id == address.id);

      if (index == -1) {
        throw Exception('Address not found');
      }

      addresses[index] = address;
      await _saveAddresses(addresses);
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    try {
      final addresses = await getAddresses();
      addresses.removeWhere((address) => address.id == id);
      await _saveAddresses(addresses);
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  @override
  Future<Address?> getAddressById(String id) async {
    try {
      final addresses = await getAddresses();
      return addresses.firstWhere(
        (address) => address.id == id,
        orElse: () => throw Exception('Address not found'),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveAddresses(List<Address> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = json.encode(
      addresses.map((address) => address.toJson()).toList(),
    );
    await prefs.setString(_storageKey, addressesJson);
  }
}

// Mock repository for testing
class MockAddressRepository implements AddressRepository {
  final List<Address> _addresses = [];

  @override
  Future<List<Address>> getAddresses() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay
    return List.from(_addresses);
  }

  @override
  Future<void> saveAddress(Address address) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newAddress = address.id.isEmpty
        ? address.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
        : address;
    _addresses.add(newAddress);
  }

  @override
  Future<void> updateAddress(Address address) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _addresses.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      _addresses[index] = address;
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _addresses.removeWhere((address) => address.id == id);
  }

  @override
  Future<Address?> getAddressById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _addresses.firstWhere((address) => address.id == id);
    } catch (e) {
      return null;
    }
  }
}
