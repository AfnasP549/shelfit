import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shelfit/features/report/customer_report/repository/customer_ledger_repository.dart';

class CustomerReportController extends GetxController {
  // Original repositories
  final CustomerLedgerReportRepository repository = CustomerLedgerReportRepository();
  // New repository for PDF generation
  final CustomerLedgerReportRepository ledgerRepository = CustomerLedgerReportRepository();
  
  // Observable variables
  final RxList<Map<String, dynamic>> customerSales = <Map<String, dynamic>>[].obs;
  final RxMap<String, double> totalSalesPerCustomer = <String, double>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedCustomer = 'All Customers'.obs;
  
  // Date range filter values
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);
  
  // Raw sales data for reporting
  final RxList<Map<String, dynamic>> salesData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomerSales();
    fetchTotalSalesPerCustomer();
    fetchSalesData();
  }
  
  // Fetch individual customer sales
  Future<void> fetchCustomerSales() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await repository.fetchCustomerSales();
      customerSales.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
      print("Error fetching customer sales: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch total sales per customer
  Future<void> fetchTotalSalesPerCustomer() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await repository.fetchTotalSalesPerCustomer();
      totalSalesPerCustomer.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
      print("Error fetching total sales per customer: $e");
    } finally {
      isLoading.value = false;
    }
  }
  
  // Fetch detailed sales data for reporting
  Future<void> fetchSalesData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      String? customerNameFilter = 
          selectedCustomer.value != 'All Customers' ? selectedCustomer.value : null;
      
      final result = await ledgerRepository.fetchCustomerSalesData(
        customerName: customerNameFilter,
        startDate: startDate.value,
        endDate: endDate.value,
      );
      
      salesData.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
      print("Error fetching sales data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Helper function to get the sorted list of customers by sales amount (highest first)
  List<MapEntry<String, double>> getSortedCustomersByTotalSales() {
    final entries = totalSalesPerCustomer.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    
    // Filter by selected customer if not "All Customers"
    if (selectedCustomer.value != 'All Customers') {
      return entries.where((entry) => entry.key == selectedCustomer.value).toList();
    }
    
    return entries;
  }
  
  // Get list of all customer names for dropdown
  List<String> getAllCustomerNames() {
    final customerNames = ['All Customers'];
    customerNames.addAll(totalSalesPerCustomer.keys.toList());
    return customerNames;
  }
  
  // Set selected customer filter
  void setSelectedCustomer(String customerName) {
    selectedCustomer.value = customerName;
    fetchSalesData(); // Refresh data when filter changes
  }
  
  // Set start date for filtering
  void setStartDate(DateTime? date) {
    startDate.value = date;
    fetchSalesData();
  }
  
  // Set end date for filtering
  void setEndDate(DateTime? date) {
    endDate.value = date;
    fetchSalesData();
  }
  
  // Reset all filters
  void resetFilters() {
    selectedCustomer.value = 'All Customers';
    startDate.value = null;
    endDate.value = null;
    fetchSalesData();
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

  // Refresh all data
  Future<void> refreshData() async {
    await fetchCustomerSales();
    await fetchTotalSalesPerCustomer();
    await fetchSalesData();
  }
  
  // Generate and print PDF report
  Future<void> printReport() async {
    try {
      isLoading.value = true;
      
      // Calculate statistics for the report
      final stats = ledgerRepository.calculateStatistics(
        salesData, 
        selectedCustomer.value != 'All Customers' ? selectedCustomer.value : null
      );
      
      final dateRange = getDateRangeString();
      
      final pdf = await ledgerRepository.generatePdfReport(
        salesData, 
        stats, 
        dateRange,
        selectedCustomer.value != 'All Customers' ? selectedCustomer.value : null
      );
      
      isLoading.value = false;
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Customer Ledger Report',
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
      
      // Calculate statistics for the report
      final stats = ledgerRepository.calculateStatistics(
        salesData, 
        selectedCustomer.value != 'All Customers' ? selectedCustomer.value : null
      );
      
      final dateRange = getDateRangeString();
      
      final pdfDocument = await ledgerRepository.generatePdfReport(
        salesData, 
        stats, 
        dateRange,
        selectedCustomer.value != 'All Customers' ? selectedCustomer.value : null
      );
      
      final path = await ledgerRepository.savePdf(pdfDocument);
      
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
        text: 'Customer Ledger Report - $dateRange ($format)',
        subject: 'Customer Ledger Report ($format)',
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
      
      // Calculate statistics for the report
      final stats = ledgerRepository.calculateStatistics(
        salesData, 
        selectedCustomer.value != 'All Customers' ? selectedCustomer.value : null
      );
      
      final dateRange = getDateRangeString();
      
      final pdfDocument = await ledgerRepository.generatePdfReport(
        salesData, 
        stats, 
        dateRange,
        selectedCustomer.value != 'All Customers' ? selectedCustomer.value : null
      );
      
      final path = await ledgerRepository.savePdf(pdfDocument);
      
      isLoading.value = false;
      
      if (path == null) {
        Get.snackbar('Error', 'Could not generate PDF for email');
        return;
      }
      
      final Email email = Email(
        subject: 'Customer Ledger Report - $dateRange',
        body: 'Please find attached the customer ledger report for $dateRange.',
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
      
      // Calculate statistics for the report
      final stats = ledgerRepository.calculateStatistics(
        salesData, 
        selectedCustomer.value != 'All Customers' ? selectedCustomer.value : null
      );
      
      final dateRange = getDateRangeString();
      
      final pdfDocument = await ledgerRepository.generatePdfReport(
        salesData, 
        stats, 
        dateRange,
        selectedCustomer.value != 'All Customers' ? selectedCustomer.value : null
      );
      
      final path = await ledgerRepository.savePdf(pdfDocument);
      
      isLoading.value = false;
      
      if (path == null) {
        Get.snackbar('Error', 'Could not generate PDF for viewing');
        return;
      }
      
      // Use printing package to show PDF
      final file = File(path);
      final bytes = await file.readAsBytes();
      await Printing.sharePdf(bytes: bytes, filename: 'customer_ledger_report.pdf');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Could not display PDF: $e');
    }
  }
}