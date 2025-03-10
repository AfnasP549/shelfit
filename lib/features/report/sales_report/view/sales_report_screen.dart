import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/widget/custom_appbar.dart';
import 'package:shelfit/features/report/sales_report/controller/sales_report_controller.dart';
import 'package:shelfit/features/report/sales_report/widget/action_button_widget.dart';
import 'package:shelfit/features/report/sales_report/widget/filter_section_widget.dart';

class SalesReportScreen extends StatelessWidget {
  final SalesReportController controller = Get.put(SalesReportController());

  SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.loadSales;
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Sales Report',
        actions: [
          ActionButtonsWidget(controller: controller),
        ],
        ),
      body: Column(
        children: [
          // Filter section
          FilterSectionWidget(controller: controller), 
          // Sales data
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Lottie.asset('asset/loading.json'),
                );
              }
              
              if (controller.filteredSales.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('asset/empty.json'),
                      const SizedBox(height: 16),
                      Text(
                        'No sales found for the selected dates',
                        style: TextStyle(
                          color: AppColor.textsecondryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Calculate stats
              final stats = controller.getReportStatistics();
              
              return Container(
                color: AppColor.primaryColor,
                child: Column(
                  children: [
                    // Stats summary
                    _buildStatsSummary(stats),
                    
                    // Sales list
                    Expanded(
                      child: _buildSalesList(),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  // Stats summary widget
  Widget _buildStatsSummary(Map<String, dynamic> stats) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: AppColor.secondryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total Sales',
              '${stats['totalSales']}',
              Icons.shopping_cart,
            ),
            _buildStatItem(
              'Revenue',
              '₹${stats['totalRevenue'].toStringAsFixed(2)}',
              Icons.attach_money,
            ),
            _buildStatItem(
              'Items Sold',
              '${stats['totalQuantity']}',
              Icons.inventory,
            ),
          ],
        ),
      ),
    );
  }
  
  // Sales list widget
  Widget _buildSalesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: controller.filteredSales.length,
      itemBuilder: (context, index) {
        var sale = controller.filteredSales[index];
        
        // Parse the date string
        String formattedDate = "Unknown date";
        try {
          DateTime saleDate = DateTime.parse(sale['saleDate']);
          formattedDate = DateFormat('MMM dd, yyyy').format(saleDate);
        } catch (e) {
          throw Exception("Error formatting date: $e");
        }
        
        return Card(
          color: AppColor.secondryColor,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColor.secondryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColor.textsecondryColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        sale['paymentMethod'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColor.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColor.primaryColor,
                          child: Text(
                            (sale['productName'] ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColor.secondryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sale['productName'] ?? 'Unknown Product',
                                style: const TextStyle(
                                  color: AppColor.textsecondryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Sold to: ${sale['customerName'] ?? 'Unknown'}",
                                style: TextStyle(
                                  color: AppColor.textfieldborderfocus,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: AppColor.primaryColor),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Quantity",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${sale['quantity'] ?? 0}",
                              style: const TextStyle(
                                color: AppColor.textsecondryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Total Amount",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₹${(sale['totalPrice'] ?? 0.0).toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.successColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Helper method to build stat items
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColor.textfieldborderfocus,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.textsecondryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

}