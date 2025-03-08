import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/widget/custom_appbar.dart';
import 'package:shelfit/features/sales/controller/sales_controller.dart';
import 'package:intl/intl.dart';

class SalesHistoryScreen extends StatelessWidget {
  final SalesController salesController = Get.find<SalesController>();

  SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    salesController.loadSales();
    
    return Scaffold(
      appBar:CustomAppbar(title: 'Sales History'),
      body: Obx(() {
        // loading
        if (salesController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               Lottie.asset('asset/loading.json'),
              ],
            ),
          );
        }
        
        // sales empty
        if (salesController.sales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Lottie.asset('asset/empty.json')
              ],
            ),
          );
        }

        return Container(
          color: AppColor.primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),  
            itemCount: salesController.sales.length,
            itemBuilder: (context, index) {
              var sale = salesController.sales[index];
              
              // Parse the date string properly
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
                          //date
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
                            //payment method
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
                                    //product
                                    Text(
                                      sale['productName'] ?? 'Unknown Product',
                                      style: const TextStyle(
                                        color: AppColor.textsecondryColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    //customer name
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
                                  //quantity number
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
                                  //price
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
          ),
        );
      }),
    );
  }
}