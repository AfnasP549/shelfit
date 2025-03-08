import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SalesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 // final String uid = FirebaseAuth.instance.currentUser!.uid;
 String? get uid{
  return FirebaseAuth.instance.currentUser?.uid;
 }

  //! Fetch customers
  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    QuerySnapshot snapshot = await _firestore
        .collection('customers')
        .where('uid', isEqualTo: uid)
        .get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  //! Fetch products
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    QuerySnapshot snapshot = await _firestore
        .collection('inventory')
        .where('userId', isEqualTo: uid) // Ensure correct field name
        .get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  //! Add Sale & Update Inventory Stock
  Future<void> addSale({
    required String customerId,
    required String productId,
    required String productName,
    required String customerName,
    required int quantity,
    required double totalPrice,
    required String paymentMethod,
    required DateTime saleDate,
  }) async {
    final DocumentReference productRef =
        _firestore.collection('inventory').doc(productId);

    return _firestore.runTransaction((transaction) async {
      // Get the product document
      DocumentSnapshot productSnapshot = await transaction.get(productRef);

      if (!productSnapshot.exists) {
        throw Exception("Product not found!");
      }

      // Get current stock
      int currentStock = (productSnapshot.data() as Map<String, dynamic>)['quantity'] ?? 0;

      if (currentStock < quantity) {
        throw Exception("Not enough stock available!");
      }

      // Reduce stock
      transaction.update(productRef, {'quantity': currentStock - quantity});

      // Add sale record
      transaction.set(_firestore.collection('sales').doc(), {
        'uid': uid,
        'customerId': customerId,
        'productId': productId,
        'customerName' : customerName,
        'productName': productName,
        'quantity': quantity,
        'totalPrice': totalPrice, // Added total price field
        'paymentMethod': paymentMethod,
        'saleDate': saleDate.toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  //! Update Stock (Used for adding/removing stock manually)
  Future<void> updateStock(String productId, int quantityChange) async {
    try {
      DocumentReference productRef =
          _firestore.collection('inventory').doc(productId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(productRef);

        if (!snapshot.exists) {
          throw Exception("Product does not exist!");
        }

        int currentStock = (snapshot.data() as Map<String, dynamic>)['quantity'] ?? 0;
        int newStock = currentStock + quantityChange; // Deduct or add quantity

        if (newStock < 0) {
          throw Exception("Insufficient stock!");
        }

        transaction.update(productRef, {'quantity': newStock});
      });
    } catch (e) {
      throw Exception("Failed to update stock");
    }
  }




  //! Fetch sales records
  // Add debugging to fetchSales method in SalesRepository
Future<List<Map<String, dynamic>>> fetchSales() async {
  try {
    if (uid == null) {
      return [];
    }
    
    // Just filter without ordering for now
    QuerySnapshot snapshot = await _firestore
        .collection('sales')
        .where('uid', isEqualTo: uid)
        // Remove the orderBy line temporarily
        .get();
    
    
    var result = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
    
    // Sort in memory instead
    result.sort((a, b) {
      var aTime = a['timestamp'] ?? a['saleDate'] ?? '';
      var bTime = b['timestamp'] ?? b['saleDate'] ?? '';
      return bTime.compareTo(aTime); // Descending order
    });
    
    return result;
  } catch (e) {
    throw Exception("Failed to fetch sales: $e");
  }
}


  

}
