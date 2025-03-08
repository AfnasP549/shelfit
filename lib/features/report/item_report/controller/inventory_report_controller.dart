import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shelfit/features/inventory_item/model/inventory_model.dart';
import 'package:shelfit/features/report/item_report/repository/inventiry_report_repo.dart';

class InventoryReportController extends GetxController {
  final InventoryReportRepository repository = InventoryReportRepository();
  
  // Observable variables
  var inventoryItems = <InventoryModel>[].obs;
  var filteredItems = <InventoryModel>[].obs;
  var isLoading = false.obs;
  
  // Date range filter values
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);
  
  @override
  void onInit() {
    super.onInit();
    loadInventory();
  }
  
  // Load all inventory data
  Future<void> loadInventory() async {
    isLoading.value = true;
    try {
      var result = await repository.fetchInventoryForReport(
        startDate: startDate.value,
        endDate: endDate.value,
      );
      inventoryItems.assignAll(result);
      filteredItems.assignAll(result);
      isLoading.value = false;
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch inventory data: $e");
      isLoading.value = false;
    }
  }
  
  // Set start date for filtering
  void setStartDate(DateTime? date) {
    startDate.value = date;
    loadInventory();
  }
  
  // Set end date for filtering
  void setEndDate(DateTime? date) {
    endDate.value = date;
    loadInventory();
  }
  
  // Reset all filters
  void resetFilters() {
    startDate.value = null;
    endDate.value = null;
    loadInventory();
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
  
  // Calculate report statistics
  Map<String, dynamic> getReportStatistics() {
    return repository.calculateStatistics(filteredItems);
  }
  
  // Generate and print PDF report
  Future<void> printReport() async {
    try {
      isLoading.value = true;
      final stats = getReportStatistics();
      final dateRange = getDateRangeString();
      
      final pdf = await repository.generatePdfReport(
        filteredItems, 
        stats, 
        dateRange
      );
      
      isLoading.value = false;
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Inventory Report',
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Could not print report: $e');
    }
  }
  
  // Share report as PDF
  Future<void> sharePdfReport() async {
    try {
      isLoading.value = true;
      
      final stats = getReportStatistics();
      final dateRange = getDateRangeString();
      
      final pdfDocument = await repository.generatePdfReport(
        filteredItems, 
        stats, 
        dateRange
      );
      
      final path = await repository.savePdf(pdfDocument);
      
      isLoading.value = false;
      
      if (path == null) {
        Get.snackbar('Error', 'Could not generate PDF file');
        return;
      }
      
      await shareFile(path, dateRange, 'PDF');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Could not share PDF report: $e');
    }
  }
  
  // Share file using share_plus
  Future<void> shareFile(String filePath, String dateRange, String format) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception("Generated file does not exist at path: $filePath");
      }
      
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Inventory Report - $dateRange ($format)',
        subject: 'Inventory Report ($format)',
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not share file: $e');
      
      // Fallback: Show file location
      Get.snackbar(
        'Report Saved', 
        '$format report saved to: $filePath\nYou can access it from your files',
        duration: const Duration(seconds: 5)
      );
    }
  }
  
  // Send report via email
  Future<void> shareViaEmail() async {
    try {
      isLoading.value = true;
      
      final stats = getReportStatistics();
      final dateRange = getDateRangeString();
      
      final pdfDocument = await repository.generatePdfReport(
        filteredItems, 
        stats, 
        dateRange
      );
      
      final path = await repository.savePdf(pdfDocument);
      
      isLoading.value = false;
      
      if (path == null) {
        Get.snackbar('Error', 'Could not generate PDF for email');
        return;
      }
      
      final Email email = Email(
        subject: 'Inventory Report - $dateRange',
        body: 'Please find attached the inventory report for $dateRange.',
        attachmentPaths: [path],
      );
      
      try {
        await FlutterEmailSender.send(email);
      } catch (e) {
        // Fallback to sharing if email fails
        await shareFile(path, dateRange, 'PDF');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Could not prepare report for email: $e');
    }
  }
  
  // View PDF in viewer
  Future<void> viewPdf() async {
    try {
      isLoading.value = true;
      
      final stats = getReportStatistics();
      final dateRange = getDateRangeString();
      
      final pdfDocument = await repository.generatePdfReport(
        filteredItems, 
        stats, 
        dateRange
      );
      
      final path = await repository.savePdf(pdfDocument);
      
      isLoading.value = false;
      
      if (path == null) {
        Get.snackbar('Error', 'Could not generate PDF for viewing');
        return;
      }
      
      // Use printing package to show PDF
      final file = File(path);
      final bytes = await file.readAsBytes();
      await Printing.sharePdf(bytes: bytes, filename: 'inventory_report.pdf');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Could not display PDF: $e');
    }
  }
}