import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/customer/controller/customer_controller.dart';

class CustomerDropdownWidget extends StatelessWidget {
  final String? selectedCustomerId;
  final ValueChanged<String?> onChanged;

  const CustomerDropdownWidget({
    super.key,
    required this.selectedCustomerId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final CustomerController customerController = Get.find<CustomerController>();

    return Obx(() {
      if (customerController.isLoading.value) {
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
        value: selectedCustomerId,
        hint: const Text("Select Customer", style: TextStyle(color: AppColor.textsecondryColor),),
        onChanged: onChanged,
        items: customerController.customers.map((customer) {
          return DropdownMenuItem<String>(
            value: customer.id,
            child: Text(customer.name, style: TextStyle(color: AppColor.textsecondryColor),),
          );
        }).toList(),
      );
    });
  }
}
