import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/inventory_item/controller/inventory_controller.dart';
import 'package:shelfit/features/inventory_item/widget/item_detail.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final InventoryController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: "Search items...",
            border: InputBorder.none,
          ),
          onChanged: (value) => controller.searchItems(value),
        ),
      ),
      body: Obx(() {
        if (controller.filteredItems.isEmpty) {
          return Center(
            child: Text(
              "No items found",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.filteredItems.length,
          itemBuilder: (context, index) {
            final item = controller.filteredItems[index];
            return Card(
              color: AppColor.bottomtertiary,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  item.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(item.description),
                trailing: Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => showItemDetails(context, item, controller),
              ),
            );
          },
        );
      }),
    );
  }
}
