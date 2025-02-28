// item_details.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/widget/custom_button.dart';
import 'package:shelfit/features/inventory_item/controller/inventory_controller.dart';
import 'package:shelfit/features/inventory_item/model/inventory_model.dart';
import 'package:shelfit/features/inventory_item/widget/popup_adjust_quantity.dart';

final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\₹');

void showItemDetails(BuildContext context, InventoryModel item, InventoryController controller) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      color: AppColor.primaryColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(item.description),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quantity: ${item.quantity}'),
              SizedBox(width: 50),
              Text(
                currencyFormat.format(item.price),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                onTap: () => adjustQuantity(context, item, true, controller),
                btnText: 'Add Stock',
                btnwidth: 50,
                btnheight: 40,
              ),
              CustomButton(
                onTap: () => adjustQuantity(context, item, false, controller),
                btnText: 'Remove Stock',
                btnheight: 40,
                btnwidth: 50,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
