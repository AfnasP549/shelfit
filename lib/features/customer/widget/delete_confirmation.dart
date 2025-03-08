import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shelfit/core/color/color.dart';
import '../controller/customer_controller.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String customerId;
  final String customerName;
  final CustomerController controller;

  const DeleteConfirmationDialog({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColor.secondryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text("Confirm Delete"),
      content: Text(
        "Are you sure you want to delete $customerName?",
        style: TextStyle(
          color: AppColor.textsecondryColor,
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: const Text(
            "Delete",
            style: TextStyle(color: AppColor.errorColor),
          ),
          onPressed: () {
            controller.deleteCustomer(customerId);
            Get.back();
          },
        ),
      ],
    );
  }
}
