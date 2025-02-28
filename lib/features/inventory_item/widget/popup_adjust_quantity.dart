import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/widget/custom_textfield.dart';
import 'package:shelfit/features/inventory_item/controller/inventory_controller.dart';
import 'package:shelfit/features/inventory_item/model/inventory_model.dart';

void adjustQuantity(BuildContext context, InventoryModel item, bool isIncrease, InventoryController controller) {
  final TextEditingController quantityController = TextEditingController();

  Get.dialog(
    AlertDialog(
      backgroundColor: AppColor.secondryColor,
      title: Text(isIncrease ? 'Add Stock' : 'Remove Stock'),
      content: CustomTextfield(
        controller: quantityController, 
        name: 'Quantity',
        inputType: TextInputType.number,
        inputTextColor: AppColor.textsecondryColor,

      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final quantity = int.tryParse(quantityController.text) ?? 0;
            if (quantity <= 0) {
              Get.snackbar('Error', 'Please enter a valid quantity');
              return;
            }

            bool success = false;
            int newQuantity = item.quantity;

            if (isIncrease) {
              success = await controller.increaseQuantity(item.id, quantity);
              if (success) {
                newQuantity += quantity;
              }
            } else {
              success = await controller.decreaseQuantity(item.id, quantity);
              if (success) {
                newQuantity -= quantity;
                if (newQuantity < 0) {
                  newQuantity = 0;
                }
              }
            }

            if (success) {
              final updatedItem = item.copyWith(quantity: newQuantity);

              final index = controller.items.indexWhere((i) => i.id == item.id);
              if (index != -1) {
                controller.items[index] = updatedItem;
                controller.items.refresh();
              }

              Get.back();
              Get.back();
              Get.snackbar(
                'Success',
                isIncrease
                    ? 'Added $quantity items to inventory'
                    : 'Removed $quantity items from inventory',
              );
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}
