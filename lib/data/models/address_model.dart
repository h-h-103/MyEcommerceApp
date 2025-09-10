class Address {
  final String id;
  final String addressTitle;
  final String fullName;
  final String street;
  final String phone;
  final String city;
  final String state;

  const Address({
    required this.id,
    required this.addressTitle,
    required this.fullName,
    required this.street,
    required this.phone,
    required this.city,
    required this.state,
  });

  // Empty constructor
  Address.empty()
    : id = '',
      addressTitle = '',
      fullName = '',
      street = '',
      phone = '',
      city = '',
      state = '';

  // Copy with method for immutability
  Address copyWith({
    String? id,
    String? addressTitle,
    String? fullName,
    String? street,
    String? phone,
    String? city,
    String? state,
  }) {
    return Address(
      id: id ?? this.id,
      addressTitle: addressTitle ?? this.addressTitle,
      fullName: fullName ?? this.fullName,
      street: street ?? this.street,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      state: state ?? this.state,
    );
  }

  // Convert to Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'addressTitle': addressTitle,
      'fullName': fullName,
      'street': street,
      'phone': phone,
      'city': city,
      'state': state,
    };
  }

  // Create from Map for JSON deserialization
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      addressTitle: json['addressTitle'] ?? '',
      fullName: json['fullName'] ?? '',
      street: json['street'] ?? '',
      phone: json['phone'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address &&
        other.id == id &&
        other.addressTitle == addressTitle &&
        other.fullName == fullName &&
        other.street == street &&
        other.phone == phone &&
        other.city == city &&
        other.state == state;
  }

  @override
  int get hashCode {
    return Object.hash(id, addressTitle, fullName, street, phone, city, state);
  }

  @override
  String toString() {
    return 'Address(id: $id, addressTitle: $addressTitle, fullName: $fullName, street: $street, phone: $phone, city: $city, state: $state)';
  }
}
