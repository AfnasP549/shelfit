  // ignore_for_file: use_build_context_synchronously

  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:lottie/lottie.dart';
  import 'package:shelfit/core/color/color.dart';
  import 'package:shelfit/core/widget/custom_appbar.dart';
  import 'package:shelfit/features/auth/service/auth_service.dart';
  import 'package:shelfit/features/auth/view/signin_screen.dart';
  import 'package:shelfit/features/inventory_item/controller/inventory_controller.dart';
  import 'package:shelfit/features/inventory_item/model/inventory_model.dart';
  import 'package:shelfit/features/inventory_item/view/add_item_screen.dart';
  import 'package:shelfit/features/inventory_item/view/inventory_edit_screen.dart';
  import 'package:shelfit/features/inventory_item/widget/delete_confirmation.dart';
  import 'package:shelfit/features/inventory_item/widget/item_detail.dart';

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
                return _buildInventoryItem(context, item);
              });
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Get.to(AddItemScreen());
          },
          child: Icon(Icons.add, color: AppColor.primaryColor, size: 30,),
          ),
      );
    }

    Widget _buildInventoryItem(BuildContext context, InventoryModel item) {
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    item.description,
                    maxLines: 5, 
                    style: TextStyle(
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      'Qty: ${item.quantity}',
                      style: TextStyle(
                        color: AppColor.textsecondryColor,
                      ),
                    ),
                    backgroundColor: AppColor.tertiaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currencyFormat.format(item.price),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColor.successColor,
                      fontSize: 25
                    ),
                  ),
                ],
              )
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'edit') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditItemScreen(itemId: item.id),
                  ),
                );

                // Refreshing the inventory
                if (result == true) {
                  controller.fetchItems();
                }
              } else if (value == 'delete') {
                InventoryDelete.confirmDelete(context, item);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => showItemDetails(context, item, controller),
        ),
      );
    }
  }
