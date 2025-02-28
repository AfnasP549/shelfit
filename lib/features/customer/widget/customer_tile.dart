import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/customer/view/customer_edit.dart';
import 'package:shelfit/features/customer/widget/delete_confirmation.dart';
import '../controller/customer_controller.dart';
import '../model/customer_model.dart';

class CustomerTile extends StatelessWidget {
  final CustomerController controller;
  final CustomerModel customer;

  const CustomerTile({
    super.key,
    required this.controller,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ListTile(
          tileColor: AppColor.secondryColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            radius: 25,
            child: Text(
              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              customer.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      customer.address,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    customer.mobileNumber,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                Get.to(() => EditCustomerScreen(customer: customer));
              } else if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteConfirmationDialog(
                      controller: controller,
                      customerId: customer.id,
                      customerName: customer.name,
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Text(
                      'Edit Customer',
                      style: TextStyle(color: AppColor.bottomprimary),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Text(
                      'Delete Customer',
                      style: TextStyle(color: AppColor.delete),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            Get.to(() => EditCustomerScreen(customer: customer));
          },
        ),
      ),
    );
  }
}
