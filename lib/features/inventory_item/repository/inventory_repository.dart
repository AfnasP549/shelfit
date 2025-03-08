  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:shelfit/features/inventory_item/model/inventory_model.dart';

  class InventoryRepository {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    
    // Get current user ID safely
    String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

    // Add new inventory item
  Future<InventoryModel> addItem({
    required String name,
    required String description,
    required int quantity,
    required double price,
  }) async {
    try {
      if (userId.isEmpty) throw Exception('User not authenticated');

      final now = DateTime.now();
      final docRef = await _firestore.collection('inventory').add({
        'name': name,
        'description': description,
        'quantity': quantity,
        'price': price,
        'userId': userId,
        'createdAt': now,
        'updatedAt': now,
      });

      // Return the full item (immediate UI update)
      return InventoryModel(
        id: docRef.id,
        name: name,
        description: description,
        quantity: quantity,
        price: price,
        userId: userId,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }


    // Get all items for current user
    Stream<List<InventoryModel>> getItems() {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('inventory')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print("Stream update: ${snapshot.docs.length} items"); // Add this for debugging
          return snapshot.docs.map((doc) {
            return InventoryModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

    // Get a specific item
    Future<InventoryModel?> getItem(String id) async {
      try {
        DocumentSnapshot doc = await _firestore.collection('inventory').doc(id).get();
        if (doc.exists) {
          return InventoryModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }
        return null;
      } catch (e) {
        throw Exception('Failed to get item: $e');
      }
    }

    // Update an item
    Future<void> updateItem({
      required String id,
      required String name,
      required String description,
      required int quantity,
      required double price,
    }) async {
      try {
        await _firestore.collection('inventory').doc(id).update({
          'name': name,
          'description': description,
          'quantity': quantity,
          'price': price,
          'updatedAt': DateTime.now(),
        });
      } catch (e) {
        throw Exception('Failed to update item: $e');
      }
    }

    // Delete an item
    Future<void> deleteItem(String id) async {
      try {
        await _firestore.collection('inventory').doc(id).delete();
      } catch (e) {
        throw Exception('Failed to delete item: $e');
      }
    }
    
    // Increase item quantity
    Future<void> increaseQuantity(String id, int amount) async {
      try {
        await _firestore.collection('inventory').doc(id).update({
          'quantity': FieldValue.increment(amount),
          'updatedAt': DateTime.now(),
        });
      } catch (e) {
        throw Exception('Failed to increase quantity: $e');
      }
    }
    
    // Decrease item quantity
    Future<void> decreaseQuantity(String id, int amount) async {
      try {
        // Get current quantity first to prevent negative values
        final doc = await _firestore.collection('inventory').doc(id).get();
        final currentQuantity = (doc.data()?['quantity'] as num?)?.toInt() ?? 0;
        
        if (currentQuantity < amount) {
          throw Exception('Insufficient quantity');
        }
        
        await _firestore.collection('inventory').doc(id).update({
          'quantity': FieldValue.increment(-amount),
          'updatedAt': DateTime.now(),
        });
      } catch (e) {
        throw Exception('Failed to decrease quantity: $e');
      }
    }
    

  }