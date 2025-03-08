import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/widget/custom_appbar.dart';
import 'package:shelfit/features/inventory_item/model/inventory_model.dart';
import 'package:shelfit/features/report/item_report/controller/inventory_report_controller.dart';
import 'package:shelfit/features/report/item_report/widget/custom_elevation_button.dart';
import 'package:shelfit/features/report/item_report/widget/filter_section_item_widget.dart';

class InventoryReportScreen extends StatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  late final InventoryReportController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(InventoryReportController());
  }

  @override
  Widget build(BuildContext context) {
    controller.loadInventory;
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Inventory Report',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: Lottie.asset('asset/loading.json'));
        }
        
        return Column(
          children: [
            FilterSectionItemWidget(controller: controller,),
            _buildActionButtonsSection(),
            _buildItemsListSection(),
          ],
        );
      }),
    );
  }
  // Items list section
  Widget _buildItemsListSection() {
    return Expanded(
      child: controller.filteredItems.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: controller.filteredItems.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return _buildItemCard(controller.filteredItems[index], index);
              },
            ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No items found for the selected period',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: controller.resetFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }

  // Item card widget
  Widget _buildItemCard(InventoryModel item, int index) {
    final totalValue = item.price * item.quantity;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Updated on: ${DateFormat('MMM dd, yyyy').format(item.updatedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(totalValue),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} × ${currencyFormat.format(item.price)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Action buttons section
  Widget _buildActionButtonsSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               CustomElevatedButton(
                icon: Icons.visibility,
                color: AppColor.successColor,
                label: 'View PDF',
                onPressed: controller.viewPdf,
              ),
                CustomElevatedButton(
                icon: Icons.share,
                color: AppColor.successColor,
                label: 'Share',
                onPressed: controller.sharePdfReport,
              ),
              CustomElevatedButton(
                icon: Icons.print,
                color: AppColor.successColor,
                label: 'Print',
                onPressed: controller.printReport,
              ),
            
              CustomElevatedButton(
                icon: Icons.email,
                color: AppColor.successColor,
                label: 'Email',
                onPressed: controller.shareViaEmail,
              ),
             
            ],
          ),
        ],
      ),
    );
  }

  // Action button widget
  Widget _buildActionButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  String? buttonName, // Optional button name
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColor.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            buttonName ?? label, // Use buttonName if provided, else fallback to label
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

}