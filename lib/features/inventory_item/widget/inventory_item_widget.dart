import 'package:flutter/material.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/inventory_item/controller/inventory_controller.dart';
import 'package:shelfit/features/inventory_item/model/inventory_model.dart';
import 'package:shelfit/features/inventory_item/view/inventory_edit_screen.dart';
import 'package:shelfit/features/inventory_item/widget/delete_confirmation.dart';

class InventoryItemWidget extends StatelessWidget {
  final InventoryModel item;
  final InventoryController controller;

  const InventoryItemWidget({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
    //  color: AppColor.tertiaryLightColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
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
                  style: const TextStyle(
                    overflow: TextOverflow.visible,
                    fontSize: 15
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    'STOCK: ${item.quantity}',
                    style: TextStyle(
                      color: AppColor.textsecondryColor,
                    ),
                  ),
                  backgroundColor: AppColor.tertiaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '₹${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
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
      //  onTap: () => showItemDetails(context, item, controller),
      ),
    );
  }
}
