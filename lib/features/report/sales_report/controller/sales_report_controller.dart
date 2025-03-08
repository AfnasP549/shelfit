import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:async';

import 'package:shelfit/features/report/sales_report/repository/sales_report_repository.dart';


class SalesReportController extends GetxController {
  final SalesReportRepository repository = SalesReportRepository();
  
  var sales = <Map<String, dynamic>>[].obs;
  var filteredSales = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  
  // Date range filter values
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);
  
  @override
  void onInit() {
    super.onInit();
    loadSales();
  }
  
  // Load all sales data
  Future<void> loadSales() async {
    isLoading.value = true;
    try {
      var result = await repository.fetchSales();
      sales.assignAll(result);
      applyFilters(); // Apply filters after loading
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch sales");
    } finally {
      isLoading.value = false;
    }
  }
  
  // Set start date for filtering
  void setStartDate(DateTime? date) {
    startDate.value = date;
    applyFilters();
  }
  
  // Set end date for filtering
  void setEndDate(DateTime? date) {
    endDate.value = date;
    applyFilters();
  }
  
  // Reset all filters
  void resetFilters() {
    startDate.value = null;
    endDate.value = null;
    applyFilters();
  }
  
  // Apply date filters to sales data
  void applyFilters() {
    if (startDate.value == null && endDate.value == null) {
      // If no filters selected, show all sales
      filteredSales.assignAll(sales);
      return;
    }
    
    List<Map<String, dynamic>> filtered = sales.where((sale) {
      try {
        DateTime saleDate = DateTime.parse(sale['saleDate']);
        
        bool matchesStartDate = startDate.value == null || 
            saleDate.isAfter(startDate.value!) || 
            isSameDay(saleDate, startDate.value!);
            
        bool matchesEndDate = endDate.value == null || 
            saleDate.isBefore(endDate.value!) || 
            isSameDay(saleDate, endDate.value!);
            
        return matchesStartDate && matchesEndDate;
      } catch (e) {
        return false;
      }
    }).toList();
    
    filteredSales.assignAll(filtered);
  }
  
  // Helper function to check if two dates are the same day
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  // Calculate report statistics
  Map<String, dynamic> getReportStatistics() {
    double totalRevenue = 0;
    int totalQuantity = 0;
    Map<String, int> productCounts = {};
    Map<String, double> productRevenue = {};
    
    for (var sale in filteredSales) {
      double price = (sale['totalPrice'] ?? 0.0);
      int qty = (sale['quantity'] ?? 0);
      String product = sale['productName'] ?? 'Unknown';
      
      totalRevenue += price;
      totalQuantity += qty;
      
      // Count by product
      if (productCounts.containsKey(product)) {
        productCounts[product] = productCounts[product]! + qty;
        productRevenue[product] = productRevenue[product]! + price;
      } else {
        productCounts[product] = qty;
        productRevenue[product] = price;
      }
    }
    
    // Sort products by revenue
    List<MapEntry<String, double>> sortedProducts = productRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Top 3 selling products
    List<String> topProducts = sortedProducts.take(3).map((e) => e.key).toList();
    
    return {
      'totalRevenue': totalRevenue,
      'totalSales': filteredSales.length,
      'totalQuantity': totalQuantity,
      'productCounts': productCounts,
      'productRevenue': productRevenue,
      'topProducts': topProducts,
    };
  }
  
  // Get date range string for reports
  String getDateRangeString() {
    final DateFormat dateFormatter = DateFormat('MMM dd, yyyy');
    String dateRange = 'All Time';
    
    if (startDate.value != null && endDate.value != null) {
      dateRange = '${dateFormatter.format(startDate.value!)} - ${dateFormatter.format(endDate.value!)}';
    } else if (startDate.value != null) {
      dateRange = 'From ${dateFormatter.format(startDate.value!)}';
    } else if (endDate.value != null) {
      dateRange = 'Until ${dateFormatter.format(endDate.value!)}';
    }
    
    return dateRange;
  }
  
  // Save Excel to device and share
  Future<void> shareExcelReport() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      final stats = getReportStatistics();
      final dateRange = getDateRangeString();
      final path = await repository.generateExcelReport(filteredSales, stats, dateRange);
      
      Get.back(); // Close loading dialog
      
      if (path == null) {
        Get.snackbar('Error', 'Could not generate Excel file');
        return;
      }
      
      try {
        // Check if file exists before sharing
        File file = File(path);
        if (!await file.exists()) {
          throw Exception("Generated file does not exist at path: $path");
        }
        
        // Try to share the file
        await shareViaPlatformShare(path, dateRange, 'Excel');
      } catch (e) {
        // Fall back to showing success with path
        Get.snackbar('Success', 'Excel saved to: $path\nYou can access it from your files', 
            duration: const Duration(seconds: 5));
      }
    } catch (e) {
      if (e is Error) {
      }
      
      Get.back(); // Ensure dialog is closed if error occurs
      Get.snackbar('Error', 'Could not prepare Excel report: $e');
    }
  }
  
  //! Alternative sharing method using share_plus package
  Future<void> shareViaPlatformShare(String filePath, String dateRange, [String format = 'PDF']) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Sales Report - $dateRange ($format)',
        subject: 'Sales Report ($format)',
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not share file: $e');
    }
  }
  
  // Send report via email with improved error handling
  Future<void> shareViaEmail() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      final stats = getReportStatistics();
      final dateRange = getDateRangeString();
      
      final pdfDocument = await repository.generatePdfReport(filteredSales, stats, dateRange);
      final path = await repository.savePdf(pdfDocument);
      
      Get.back(); // Close loading dialog
      
      if (path == null) return;
      
      final Email email = Email(
        subject: 'Sales Report - $dateRange',
        body: 'Please find attached the sales report for $dateRange.',
        attachmentPaths: [path],
      );
      
      try {
        await FlutterEmailSender.send(email);
      } catch (e) {
        
        // If no email client is found, use Share.shareFiles instead
        await shareViaPlatformShare(path, dateRange);
      }
    } catch (e) {
      Get.back(); // Ensure dialog is closed if error occurs
      Get.snackbar('Error', 'Could not prepare report: $e');
    }
  }
  
  // Print report
  Future<void> printReport() async {
    try {
      final stats = getReportStatistics();
      final dateRange = getDateRangeString();
      final pdf = await repository.generatePdfReport(filteredSales, stats, dateRange);
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Sales Report',
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not print report: $e');
    }
  }
  
  // View PDF (opens in PDF viewer)
  Future<void> viewPdf() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      final stats = getReportStatistics();
      final dateRange = getDateRangeString();
      
      final pdfDocument = await repository.generatePdfReport(filteredSales, stats, dateRange);
      final path = await repository.savePdf(pdfDocument);
      
      Get.back(); // Close loading dialog
      
      if (path == null) return;
      
      // Use printing package to show PDF
      final file = File(path);
      final bytes = await file.readAsBytes();
      await Printing.sharePdf(bytes: bytes, filename: 'sales_report.pdf');
    } catch (e) {
      Get.back(); // Ensure dialog is closed if error occurs
      Get.snackbar('Error', 'Could not display PDF: $e');
    }
  }
}