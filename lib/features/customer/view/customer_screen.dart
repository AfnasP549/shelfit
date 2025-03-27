import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/widget/custom_appbar.dart';
import 'package:shelfit/features/customer/view/customer_add.dart';
import 'package:shelfit/features/customer/widget/customer_tile.dart';
import '../controller/customer_controller.dart';

class CustomerScreen extends StatelessWidget {
  final CustomerController controller = Get.put(CustomerController());

  CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchCustomers();

    return Scaffold(
      appBar: CustomAppbar(
        title: 'CUSTOMERS',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'asset/loading.json',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Loading customers...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColor.texttertiaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.customers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'asset/empty customer.json',
                  width: 220,
                  height: 220,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No customers found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView.separated(
            itemCount: controller.customers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final customer = controller.customers[index];
              return CustomerTile(
                controller: controller,
                customer: customer,
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(AddCustomerScreen());
        },
        child: Icon(
          Icons.add,
          color: AppColor.iconPrimay,
        ),
      ),
    );
  }
}
