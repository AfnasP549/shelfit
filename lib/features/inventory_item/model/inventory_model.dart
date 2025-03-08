class InventoryModel {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create from Firebase Map
  factory InventoryModel.fromMap(String id, Map<String, dynamic> map) {
    return InventoryModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      userId: map['userId'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
  
  // Create a copy with updated values
  InventoryModel copyWith({
    String? name,
    String? description,
    int? quantity,
    double? price,
    DateTime? updatedAt,
  }) {
    return InventoryModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}