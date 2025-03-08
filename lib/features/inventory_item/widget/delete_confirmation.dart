import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shelfit/features/inventory_item/controller/inventory_controller.dart';
import 'package:shelfit/features/inventory_item/model/inventory_model.dart';

class InventoryDelete {
  static void confirmDelete(BuildContext context, InventoryModel item) {
    final controller = Get.find<InventoryController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              bool success = await controller.deleteItem(item.id);
              if (success) {
                controller.items.removeWhere((element) => element.id == item.id);
                Get.snackbar('Success', 'Item deleted successfully');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
  