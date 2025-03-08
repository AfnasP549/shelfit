import 'dart:developer';

import 'package:get/get.dart';
import 'package:shelfit/features/inventory_item/model/inventory_model.dart';
import 'package:shelfit/features/inventory_item/repository/inventory_repository.dart';

class InventoryController extends GetxController {
  final InventoryRepository _repository = InventoryRepository();

  // Observable variables
  final RxList<InventoryModel> items = <InventoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isAdding = false.obs;
  final filteredItems = <InventoryModel>[].obs;
  final RxString error = ''.obs;


  @override
  void onInit() {
    super.onInit();
  }

   Future<void> fetchItems() async {
    isLoading.value = true;
    error.value = '';
    
    try {
      // Set up stream subscription
      _repository.getItems().listen(
        (itemsList) {
          items.value = itemsList;
          isLoading.value = false;
        },
        onError: (e) {
          error.value = 'Failed to load items: $e';
          isLoading.value = false;
        }
      );
    } catch (e) {
      log('Stream error: $e');
      error.value = 'Failed to connect to database';
      isLoading.value = false;
    }
  }

    // Add new item
  Future<bool> addItem({
    required String name,
    required String description,
    required int quantity,
    required double price,
  }) async {
    isAdding.value = true;
    error.value = '';

    try {
      final newItem = await _repository.addItem(
        name: name,
        description: description,
        quantity: quantity,
        price: price,
      );
      
      // Add to local list immediately for instant UI update
      items.add(newItem);
      
      isAdding.value = false;
      return true;
    } catch (e) {
      error.value = 'Failed to add item: $e';
      isAdding.value = false;
      return false;
    }
  }



  // Update item
  Future<bool> updateItem({
    required String id,
    required String name,
    required String description,
    required int quantity,
    required double price,
  }) async {
    isLoading.value = true;
    error.value = '';

    try {
      await _repository.updateItem(
        id: id,
        name: name,
        description: description,
        quantity: quantity,
        price: price,
      );

      // No need to update local list - stream will handle it
      isLoading.value = false;
      return true;
    } catch (e) {
      error.value = 'Failed to update item: $e';
      isLoading.value = false;
      return false;
    }
  }

  // Delete item
  Future<bool> deleteItem(String id) async {
    isLoading.value = true;
    error.value = '';

    try {
      await _repository.deleteItem(id);
      
      // No need to update local list - stream will handle it
      isLoading.value = false;
      return true;
    } catch (e) {
      error.value = 'Failed to delete item: $e';
      isLoading.value = false;
      return false;
    }
  }

  // Get a single item (useful for editing)
  Future<InventoryModel?> getItem(String id) async {
    error.value = '';

    try {
      final item = await _repository.getItem(id);
      return item;
    } catch (e) {
      error.value = 'Failed to get item: $e';
      return null;
    }
  }

  // Increase quantity
  Future<bool> increaseQuantity(String id, int amount) async {
    try {
      await _repository.increaseQuantity(id, amount);
      // No need to update local list - stream will handle it
      return true;
    } catch (e) {
      error.value = 'Failed to increase quantity: $e';
      return false;
    }
  }

  // Decrease quantity
  Future<bool> decreaseQuantity(String id, int amount) async {
    try {
      await _repository.decreaseQuantity(id, amount);
      // No need to update local list - stream will handle it
      return true;
    } catch (e) {
      error.value = 'Failed to decrease quantity: $e';
      return false;
    }
  }

  //!search
  void searchItems(String query) {
    if (query.isEmpty) {
      filteredItems.assignAll(items);
    } else {
      var results = items.where((item) =>
          item.name.toLowerCase().contains(query.toLowerCase())).toList();
      filteredItems.assignAll(results);
    }
  }
}