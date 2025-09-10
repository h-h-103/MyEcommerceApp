class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? offerPercentage;
  final String? description;
  final List<int>? colors;
  final List<String>? sizes;
  final List<String> images;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.offerPercentage,
    this.description,
    this.colors,
    this.sizes,
    required this.images,
    this.createdAt,
  });

  // Default constructor
  Product.empty()
    : id = '',
      name = '',
      category = '',
      price = 0.0,
      offerPercentage = null,
      description = null,
      colors = null,
      sizes = null,
      images = [],
      createdAt = null;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'offerPercentage': offerPercentage,
      'description': description,
      'colors': colors,
      'sizes': sizes,
      'images': images,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  // Create from Firestore document
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      offerPercentage: map['offerPercentage']?.toDouble(),
      description: map['description'],
      colors: map['colors'] != null ? List<int>.from(map['colors']) : null,
      sizes: map['sizes'] != null ? List<String>.from(map['sizes']) : null,
      images: List<String>.from(map['images'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
    );
  }

  // Copy with method for updates
  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    double? offerPercentage,
    String? description,
    List<int>? colors,
    List<String>? sizes,
    List<String>? images,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      offerPercentage: offerPercentage ?? this.offerPercentage,
      description: description ?? this.description,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
