class SalesModel {
  final String id;
  final String uid; // User's UID
  final String customerName;
  final String productName;
  final int quantity;
  final String paymentMethod;
  final DateTime saleDate;

  SalesModel({
    required this.id,
    required this.uid,
    required this.customerName,
    required this.productName,
    required this.quantity,
    required this.paymentMethod,
    required this.saleDate,
  });

  /// Convert model to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Storing the document ID (optional but useful)
      'uid': uid,
      'customerName': customerName,
      'productName': productName,
      'quantity': quantity,
      'paymentMethod': paymentMethod,
      'saleDate': saleDate.toIso8601String(),
    };
  }

  /// Create an instance from Firestore document data
  factory SalesModel.fromMap(Map<String, dynamic> map, String id) {
    return SalesModel(
      id: id.isNotEmpty ? id : 'unknown', // Ensure `id` is not empty
      uid: map['uid'] ?? '',
      customerName: map['customerName'] ?? 'Unknown Customer',
      productName: map['productName'] ?? 'Unknown Product',
      quantity: (map['quantity'] is int) ? map['quantity'] : 0, // Ensure it's an integer
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      saleDate: _parseDate(map['saleDate']),
    );
  }

  /// Helper method to parse date safely
  static DateTime _parseDate(dynamic date) {
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}