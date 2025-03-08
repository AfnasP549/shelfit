import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/report/customer_report/controller/customer_ledger_controller.dart';

class CustomerLedgerReportScreen extends StatelessWidget {
  final CustomerReportController controller = Get.put(CustomerReportController());
  final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '₹');
  final dateFormat = DateFormat('MMM dd, yyyy');

  CustomerLedgerReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.refreshData();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Ledger Report'),
        actions: [
          _buildShareMenu(context),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return  Center(child: Lottie.asset('asset/loading.json'));
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${controller.errorMessage.value}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.refreshData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildFilterSection(context),
  
            Expanded(child: _buildSalesDataList()),
          ],
        );
      }),
    );
  }

  Widget _buildShareMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Share Options',
      onSelected: (value) async {
        switch (value) {
          case 'print':
            await controller.printReport();
            break;
          case 'pdf':
            await controller.sharePdfReport();
            break;
          case 'email':
            await controller.shareViaEmail();
            break;
          case 'view':
            await controller.viewPdf();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'print',
          child: ListTile(
            leading: Icon(Icons.print),
            title: Text('Print Report'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'pdf',
          child: ListTile(
            leading: Icon(Icons.share),
            title: Text('Share PDF'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'email',
          child: ListTile(
            leading: Icon(Icons.email),
            title: Text('Send via Email'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'view',
          child: ListTile(
            leading: Icon(Icons.visibility),
            title: Text('View PDF'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Customer',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: controller.selectedCustomer.value,
                    items: controller.getAllCustomerNames().map((name) {
                      return DropdownMenuItem(
                        value: name,
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.setSelectedCustomer(value);
                      }
                    },
                  )),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesDataList() {
    return Obx(() {
      if (controller.salesData.isEmpty) {
        return const Center(
          child: Text(
            'No sales data found for the selected filters',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: controller.salesData.length,
        itemBuilder: (context, index) {
          final sale = controller.salesData[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                sale['customerName'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(sale['createdAt']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.payment,
                        size: 14,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${sale['paymentMethod']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Text(
                currencyFormat.format(sale['totalPrice']),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.successColor
                ),
              ),
            ),
          );
        },
      );
    });
  }
}