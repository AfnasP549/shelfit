import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/widget/custom_appbar.dart';
import 'package:shelfit/features/inventory_item/model/inventory_model.dart';
import 'package:shelfit/features/report/item_report/controller/inventory_report_controller.dart';
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
        actions: [
          _buildActionButtonsSection(),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: Lottie.asset('asset/loading.json'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              FilterSectionItemWidget(controller: controller),
              _buildItemsListSection(),
            ],
          ),
        );
      }),
    );
  }

  // Items list section
  Widget _buildItemsListSection() {
    return controller.filteredItems.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            shrinkWrap: true,   // Important for scrollable content
            physics: const NeverScrollableScrollPhysics(), // Prevent nested scrolling issues
            itemCount: controller.filteredItems.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              return _buildItemCard(controller.filteredItems[index], index);
            },
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
                color: AppColor.circleBg,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: AppColor.textQuaternaryColor,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildShareMenu(context),
          ],
        ),
      ],
    );
  }

  Widget _buildShareMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Options',
      onSelected: (value) async {
        switch (value) {
          case 'view':
            await controller.viewPdf();
            break;
          case 'share':
            await controller.sharePdfReport();
            break;
          case 'print':
            await controller.printReport();
            break;
          case 'email':
            await controller.shareViaEmail();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: ListTile(
            leading: Icon(Icons.visibility),
            title: Text('View PDF'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          child: ListTile(
            leading: Icon(Icons.share),
            title: Text('Share'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'print',
          child: ListTile(
            leading: Icon(Icons.print),
            title: Text('Print'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'email',
          child: ListTile(
            leading: Icon(Icons.email),
            title: Text('Email'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
