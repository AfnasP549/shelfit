import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:shelfit/features/inventory_item/model/inventory_model.dart';

class InventoryReportRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user ID safely
  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // Get inventory data for reports (can be filtered by date range)
  Future<List<InventoryModel>> fetchInventoryForReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Start with base query for current user
      Query query = _firestore
          .collection('inventory')
          .where('userId', isEqualTo: userId);

      // Apply date filters if provided
      if (startDate != null) {
        query = query.where('updatedAt', isGreaterThanOrEqualTo: startDate);
      }
      
      if (endDate != null) {
        // Add one day to include the end date fully
        final nextDay = endDate.add(const Duration(days: 1));
        query = query.where('updatedAt', isLessThan: nextDay);
      }

      // Execute query and convert results
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        return InventoryModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory data: $e');
    }
  }

  // Generate PDF report
  Future<pw.Document> generatePdfReport(
    List<InventoryModel> items,
    Map<String, dynamic> stats,
    String dateRange,
  ) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    // Add pages to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildReportHeader(dateRange),
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
                pw.Text('Inventory Summary', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem('Total Items', '${stats['totalItems']}'),
                    _buildSummaryItem('Total Value', currencyFormat.format(stats['totalValue'])),
                    _buildSummaryItem('Avg. Price', currencyFormat.format(stats['averagePrice'])),
                  ],
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Inventory table
          pw.Text('Inventory Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 10),
          _buildInventoryTable(items, currencyFormat),
        ],
      ),
    );

    return pdf;
  }

  // Build PDF header
  pw.Widget _buildReportHeader(String dateRange) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Inventory Report', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
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
        pw.Text('ShelfIt Inventory Report', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
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

  // Build inventory table
  pw.Widget _buildInventoryTable(
    List<InventoryModel> items,
    NumberFormat currencyFormat,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableCell('No.', isHeader: true),
            _tableCell('Item Name', isHeader: true),
            _tableCell('Qty', isHeader: true),
            _tableCell('Price', isHeader: true),
            _tableCell('Total Value', isHeader: true),
          ],
        ),
        // Data rows
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final totalValue = item.price * item.quantity;
          
          return pw.TableRow(
            children: [
              _tableCell('${index + 1}'),
              _tableCell(item.name),
              _tableCell('${item.quantity}'),
              _tableCell(currencyFormat.format(item.price)),
              _tableCell(currencyFormat.format(totalValue)),
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
      final fileName = 'inventory_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      return filePath;
    } catch (e) {
      print('Error saving PDF: $e');
      return null;
    }
  }

  // Calculate report statistics
  Map<String, dynamic> calculateStatistics(List<InventoryModel> items) {
    double totalValue = 0;
    double totalPrice = 0;
    int totalItems = items.length;
    
    for (var item in items) {
      totalValue += (item.price * item.quantity);
      totalPrice += item.price;
    }
    
    double averagePrice = totalItems > 0 ? totalPrice / totalItems : 0;
    
    return {
      'totalItems': totalItems,
      'totalValue': totalValue,
      'averagePrice': averagePrice,
    };
  }
}