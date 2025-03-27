import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/inventory_item/controller/inventory_controller.dart';

class ProductDropdown extends StatelessWidget {
  final String? selectedProductId;
  final ValueChanged<String?> onChanged;

  const ProductDropdown({
    super.key,
    required this.selectedProductId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final InventoryController inventoryController = Get.find<InventoryController>();

    return Obx(() {
      if (inventoryController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return DropdownButtonFormField<String>(
        dropdownColor: AppColor.dropdownPrimary,
        borderRadius: BorderRadius.circular(30),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColor.textfieldborder),
          ),
        ),
        icon: Icon(Icons.arrow_drop_down,color: AppColor.iconPrimay,),
        value: selectedProductId,
        hint: const Text("Select Product", style: TextStyle(color: AppColor.textsecondryColor),),
        onChanged: onChanged,
        items: inventoryController.items.map((product) {
          return DropdownMenuItem<String>(
            value: product.id,
            child: Text(product.name, style: TextStyle(color: AppColor.textsecondryColor),),
          );
        }).toList(),
      );
    });
  }
}
