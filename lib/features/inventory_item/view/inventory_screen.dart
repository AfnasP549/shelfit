// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/widget/custom_appbar.dart';
import 'package:shelfit/features/auth/service/auth_service.dart';
import 'package:shelfit/features/auth/view/signin_screen.dart';
import 'package:shelfit/features/inventory_item/controller/inventory_controller.dart';
import 'package:shelfit/features/inventory_item/view/add_item_screen.dart';
import 'package:shelfit/features/inventory_item/view/search_screen.dart';
import 'package:shelfit/features/inventory_item/widget/inventory_item_widget.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late final InventoryController controller;
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    controller = Get.put(InventoryController(), permanent: true);
    controller.fetchItems();
  }

  signout() async {
    await _auth.signout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SigninScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Inventory',
        actions: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: AppColor.tertiaryColor),
            child: IconButton(
                onPressed: () {
                  Get.to(SearchScreen());
                },
                icon: Icon(
                  Icons.search,
                  color: AppColor.iconPrimay,
                )),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: Lottie.asset('asset/loading.json'));
        }
        if (controller.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'asset/empty.json',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                const Text(
                  'No items found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return InventoryItemWidget(
                item: item,
                controller: controller,
              );
            });
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(AddItemScreen());
        },
        child: Icon(
          Icons.add,
          color: AppColor.primaryColor,
          size: 30,
        ),
      ),
    );
  }
}
