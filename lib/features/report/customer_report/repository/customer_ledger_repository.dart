import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CustomerLedgerReportRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user ID safely
  String get userId => _auth.currentUser?.uid ?? '';

  // Fetch customer sales data for the report
  Future<List<Map<String, dynamic>>> fetchCustomerSalesData({
    String? customerName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Start with base query for current user
      Query query = _firestore
          .collection('sales')
          .where('uid', isEqualTo: userId);
      
      // Apply customer filter if provided
      if (customerName != null && customerName != 'All Customers') {
        query = query.where('customerName', isEqualTo: customerName);
      }

      // Apply date filters if provided
      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
      }
      
      if (endDate != null) {
        // Add one day to include the end date fully
        final nextDay = endDate.add(const Duration(days: 1));
        query = query.where('createdAt', isLessThan: nextDay);
      }

      // Execute query and map results
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Convert Timestamp to DateTime
        DateTime saleDate;
        if (data['createdAt'] is Timestamp) {
          saleDate = (data['createdAt'] as Timestamp).toDate();
        } else {
          saleDate = DateTime.now(); // Fallback if date not available
        }
        
        return {
          'id': doc.id,
          'customerName': data['customerName'] ?? 'Unknown Customer',
          'totalPrice': (data['totalPrice'] as num).toDouble(),
          'createdAt': saleDate,
          'paymentMethod': data['paymentMethod'] ?? 'Unknown',
          'paymentStatus': data['paymentStatus'] ?? 'Unknown',
          'items': data['items'] ?? [],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch customer sales data: $e');
    }
  }

  // ADDING THE MISSING METHODS THAT THE CONTROLLER IS CALLING

  // Method to fetch customer sales (missing in original repository)
  Future<List<Map<String, dynamic>>> fetchCustomerSales() async {
    try {
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Query the sales collection for the current user
      final snapshot = await _firestore
          .collection('sales')
          .where('uid', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Convert Timestamp to DateTime
        DateTime saleDate;
        if (data['createdAt'] is Timestamp) {
          saleDate = (data['createdAt'] as Timestamp).toDate();
        } else {
          saleDate = DateTime.now(); // Fallback
        }
        
        return {
          'id': doc.id,
          'customerName': data['customerName'] ?? 'Unknown Customer',
          'totalPrice': (data['totalPrice'] as num).toDouble(),
          'createdAt': saleDate,
          'paymentMethod': data['paymentMethod'] ?? 'Unknown',
          'paymentStatus': data['paymentStatus'] ?? 'Unknown',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch customer sales: $e');
    }
  }

  // Method to fetch total sales per customer (missing in original repository)
  Future<Map<String, double>> fetchTotalSalesPerCustomer() async {
    try {
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Query the sales collection for the current user
      final snapshot = await _firestore
          .collection('sales')
          .where('uid', isEqualTo: userId)
          .get();
      
      // Map to hold customer name -> total sales amount
      final Map<String, double> totalSalesMap = {};
      
      // Process each sale to aggregate by customer
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String customerName = data['customerName'] ?? 'Unknown Customer';
        double amount = (data['totalPrice'] as num).toDouble();
        
        if (totalSalesMap.containsKey(customerName)) {
          totalSalesMap[customerName] = totalSalesMap[customerName]! + amount;
        } else {
          totalSalesMap[customerName] = amount;
        }
      }
      
      return totalSalesMap;
    } catch (e) {
      throw Exception('Failed to fetch total sales per customer: $e');
    }
  }

  // Calculate statistics for the report
  Map<String, dynamic> calculateStatistics(List<Map<String, dynamic>> sales, String? customerName) {
    double totalSales = 0;
    int transactionCount = sales.length;
    Map<String, double> salesPerCustomer = {};
    
    for (var sale in sales) {
      final customer = sale['customerName'];
      final amount = sale['totalPrice'];
      
      totalSales += amount;
      
      if (salesPerCustomer.containsKey(customer)) {
        salesPerCustomer[customer] = salesPerCustomer[customer]! + amount;
      } else {
        salesPerCustomer[customer] = amount;
      }
    }
    
    // Sort customers by sales amount (highest first)
    var sortedCustomers = salesPerCustomer.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    // Get top 5 customers
    var topCustomers = sortedCustomers.take(5).toList();
    
    // Calculate average transaction value
    double averageTransactionValue = transactionCount > 0 ? totalSales / transactionCount : 0;
    
    return {
      'totalSales': totalSales,
      'transactionCount': transactionCount,
      'averageTransactionValue': averageTransactionValue,
      'topCustomers': topCustomers,
      'customerCount': salesPerCustomer.length,
    };
  }

  // Generate PDF report
  Future<pw.Document> generatePdfReport(
    List<Map<String, dynamic>> sales,
    Map<String, dynamic> stats,
    String dateRange,
    String? customerName,
  ) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final dateFormat = DateFormat('MMM dd, yyyy');

    // Add pages to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildReportHeader(dateRange, customerName),
        footer: (context) => _buildReportFooter(context),
        build: (context) => [
          // Report summary section
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Customer Ledger Summary', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem('Total Sales', currencyFormat.format(stats['totalSales'])),
                    _buildSummaryItem('Transactions', '${stats['transactionCount']}'),
                    _buildSummaryItem('Avg. Value', currencyFormat.format(stats['averageTransactionValue'])),
                  ],
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Customer Sales Table
          pw.Text('Transaction Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 10),
          _buildTransactionsTable(sales, currencyFormat, dateFormat),
          
          // If showing all customers, add a top customers section
          if (customerName == null || customerName == 'All Customers') ...[
            pw.SizedBox(height: 20),
            pw.Text('Top Customers', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 10),
            _buildTopCustomersTable(stats['topCustomers'], currencyFormat),
          ],
        ],
      ),
    );

    return pdf;
  }

  // Build PDF header
  pw.Widget _buildReportHeader(String dateRange, String? customerName) {
    String title = 'Customer Ledger Report';
    if (customerName != null && customerName != 'All Customers') {
      title = 'Customer Ledger: $customerName';
    }
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
        pw.SizedBox(height: 4),
        pw.Text('Date Range: $dateRange', style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 4),
        pw.Text('Generated on: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}', 
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Divider(),
      ],
    );
  }

  // Build PDF footer
  pw.Widget _buildReportFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('ShelfIt Customer Ledger Report', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
  }

  // Build summary item box
  pw.Widget _buildSummaryItem(String title, String value) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  // Build transactions table
  pw.Widget _buildTransactionsTable(
    List<Map<String, dynamic>> sales,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.7),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.3),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableCell('No.', isHeader: true),
            _tableCell('Customer', isHeader: true),
            _tableCell('Date', isHeader: true),
            _tableCell('Amount', isHeader: true),
            _tableCell('Status', isHeader: true),
          ],
        ),
        // Data rows
        ...sales.asMap().entries.map((entry) {
          final index = entry.key;
          final sale = entry.value;
          
          return pw.TableRow(
            children: [
              _tableCell('${index + 1}'),
              _tableCell(sale['customerName']),
              _tableCell(dateFormat.format(sale['createdAt'])),
              _tableCell(currencyFormat.format(sale['totalPrice'])),
              _tableCell(sale['paymentStatus']),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Build top customers table
  pw.Widget _buildTopCustomersTable(
    List<MapEntry<String, double>> topCustomers,
    NumberFormat currencyFormat,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.7),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableCell('Rank', isHeader: true),
            _tableCell('Customer Name', isHeader: true),
            _tableCell('Total Sales', isHeader: true),
          ],
        ),
        // Data rows
        ...topCustomers.asMap().entries.map((entry) {
          final index = entry.key;
          final customer = entry.value;
          
          return pw.TableRow(
            children: [
              _tableCell('${index + 1}'),
              _tableCell(customer.key),
              _tableCell(currencyFormat.format(customer.value)),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Helper for table cells
  pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  // Save PDF to file
  Future<String?> savePdf(pw.Document pdf) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'customer_ledger_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      return filePath;
    } catch (e) {
      print('Error saving PDF: $e');
      return null;
    }
  }
}