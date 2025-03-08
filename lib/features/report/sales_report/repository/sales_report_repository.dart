// ignore_for_file: deprecated_member_use, avoid_function_literals_in_foreach_calls

import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

import 'package:shelfit/features/sales/repository/sales_repository.dart';

class SalesReportRepository {
  final SalesRepository salesRepository = SalesRepository();
  
  // Load all sales data
  Future<List<Map<String, dynamic>>> fetchSales() async {
    try {
      // Check if user is logged in first
      if (salesRepository.uid == null) {
        await Future.delayed(Duration(seconds: 1)); // Wait briefly
        if (salesRepository.uid == null) {
          throw Exception("Please log in to view sales");
        }
      }
      
      var result = await salesRepository.fetchSales();
      return result;
    } catch (e) {
      throw Exception("Failed to fetch sales: $e");
    }
  }
  
  //! Generate PDF report
  Future<pw.Document> generatePdfReport(List<Map<String, dynamic>> filteredSales, Map<String, dynamic> stats, String dateRange) async {
    final pdf = pw.Document();
    final DateFormat dateFormatter = DateFormat('MMM dd, yyyy');
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Sales Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Date Range: $dateRange', style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 8),
            pw.Divider(),
          ],
        ),
        build: (context) => [
          // Summary section
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _summaryItem('Total Sales', '${stats['totalSales']}'),
                    _summaryItem('Total Items Sold', '${stats['totalQuantity']}'),
                    _summaryItem('Total Revenue', '₹${stats['totalRevenue'].toStringAsFixed(2)}'),
                  ],
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 24),
          
          // Top Products
          pw.Text('Top Selling Products', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          
          pw.Table.fromTextArray(
            headers: ['Product', 'Quantity Sold', 'Revenue'],
            data: (stats['productCounts'] as Map<String, int>).entries.map((entry) {
              return [
                entry.key,
                entry.value.toString(),
                '₹${(stats['productRevenue'][entry.key] ?? 0.0).toStringAsFixed(2)}',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            border: null,
            headerDecoration: const pw.BoxDecoration(
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
              color: PdfColors.grey300,
            ),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerRight,
            },
          ),
          
          pw.SizedBox(height: 24),
          
          // Detailed sales
          pw.Text('Detailed Sales', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          
          pw.Table.fromTextArray(
            headers: ['Date', 'Product', 'Customer', 'Quantity', 'Payment Method', 'Amount'],
            data: filteredSales.map((sale) {
              DateTime saleDate;
              try {
                saleDate = DateTime.parse(sale['saleDate']);
              } catch (e) {
                saleDate = DateTime.now();
              }
              
              return [
                dateFormatter.format(saleDate),
                sale['productName'] ?? 'Unknown',
                sale['customerName'] ?? 'Unknown',
                (sale['quantity'] ?? 0).toString(),
                sale['paymentMethod'] ?? 'Unknown',
                '₹${(sale['totalPrice'] ?? 0.0).toStringAsFixed(2)}',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            border: null,
            headerDecoration: const pw.BoxDecoration(
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
              color: PdfColors.grey300,
            ),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.centerRight,
            },
          ),
        ],
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Generated on ${dateFormatter.format(DateTime.now())}'),
            pw.Text('Page ${context.pageNumber} of ${context.pagesCount}'),
          ],
        ),
      ),
    );
    
    return pdf;
  }
  
  // Helper for PDF generation
  pw.Widget _summaryItem(String title, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 8),
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }
  
  // Save PDF to device
  Future<String?> savePdf(pw.Document pdf) async {
    try {
      final output = await getExternalStorageDirectory();
      
      if (output == null) {
        throw Exception("Could not access external storage");
      }
      
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${output.path}/sales_report_$dateStr.pdf';
      final file = File(filePath);
      
      await file.writeAsBytes(await pdf.save());
      return filePath;
    } catch (e) {
      return null;
    }
  }
  
  // Generate Excel report
  Future<String?> generateExcelReport(List<Map<String, dynamic>> filteredSales, Map<String, dynamic> stats, String dateRange) async {
    try {
      final DateFormat dateFormatter = DateFormat('MMM dd, yyyy');
      
      // Create Excel document
      var excel = Excel.createExcel();
      
      // Remove the default sheet
      excel.delete('Sheet1');
      
      // Create Summary sheet
      var summarySheet = excel['Summary'];
      
      // Title
      var cellTitle = summarySheet.cell(CellIndex.indexByString("A1"));
      cellTitle.value = TextCellValue("Sales Report");
      cellTitle.cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
      );
      
      // Date Range
      var cellDateRange = summarySheet.cell(CellIndex.indexByString("A2"));
      cellDateRange.value = TextCellValue("Date Range: $dateRange");
      
      // Summary headers
      var rowIndex = 4;
      summarySheet.cell(CellIndex.indexByString("A$rowIndex")).value = TextCellValue("Summary Statistics");
      summarySheet.cell(CellIndex.indexByString("A$rowIndex")).cellStyle = CellStyle(bold: true);
      
      rowIndex += 2;
      summarySheet.cell(CellIndex.indexByString("A$rowIndex")).value = TextCellValue("Total Sales");
      summarySheet.cell(CellIndex.indexByString("B$rowIndex")).value = TextCellValue("${stats['totalSales']}");
      
      rowIndex += 1;
      summarySheet.cell(CellIndex.indexByString("A$rowIndex")).value = TextCellValue("Total Items Sold");
      summarySheet.cell(CellIndex.indexByString("B$rowIndex")).value = TextCellValue("${stats['totalQuantity']}");
      
      rowIndex += 1;
      summarySheet.cell(CellIndex.indexByString("A$rowIndex")).value = TextCellValue("Total Revenue");
      summarySheet.cell(CellIndex.indexByString("B$rowIndex")).value = TextCellValue("₹${stats['totalRevenue'].toStringAsFixed(2)}");
      
      // Top Products
      rowIndex += 2;
      summarySheet.cell(CellIndex.indexByString("A$rowIndex")).value = TextCellValue("Top Selling Products");
      summarySheet.cell(CellIndex.indexByString("A$rowIndex")).cellStyle = CellStyle(bold: true);
      
      rowIndex += 1;
      var headerRow = ["Product", "Quantity Sold", "Revenue"];
      for (var i = 0; i < headerRow.length; i++) {
        var cell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
        cell.value = TextCellValue(headerRow[i]);
        cell.cellStyle = CellStyle(
          bold: true,
        );
      }
      
      rowIndex += 1;
      (stats['productCounts'] as Map<String, int>).entries.forEach((entry) {
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = TextCellValue(entry.key);
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = TextCellValue(entry.value.toString());
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = TextCellValue('₹${(stats['productRevenue'][entry.key] ?? 0.0).toStringAsFixed(2)}');
        rowIndex += 1;
      });
      
      // Create Detailed Sales sheet
      var detailSheet = excel['Detailed Sales'];
      
      // Headers for detailed sales
      rowIndex = 0;
      var detailHeaders = ['Date', 'Product', 'Customer', 'Quantity', 'Payment Method', 'Amount'];
      
      for (var i = 0; i < detailHeaders.length; i++) {
        var cell = detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
        cell.value = TextCellValue(detailHeaders[i]);
        cell.cellStyle = CellStyle(
          bold: true,
        );
      }
      
      // Add all sales data
      for (var i = 0; i < filteredSales.length; i++) {
        var sale = filteredSales[i];
        DateTime saleDate;
        try {
          saleDate = DateTime.parse(sale['saleDate']);
        } catch (e) {
          saleDate = DateTime.now();
        }
        
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(dateFormatter.format(saleDate));
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = TextCellValue(sale['productName'] ?? 'Unknown');
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = TextCellValue(sale['customerName'] ?? 'Unknown');
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = TextCellValue((sale['quantity'] ?? 0).toString());
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = TextCellValue(sale['paymentMethod'] ?? 'Unknown');
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = TextCellValue('₹${(sale['totalPrice'] ?? 0.0).toStringAsFixed(2)}');
      }
      
      // Auto-size columns for better readability
      for (var sheet in excel.sheets.values) {
        for (var i = 0; i < 6; i++) {
          sheet.setColumnWidth(i, 15);
        }
      }
      
      // Save the Excel file - try different approaches for file saving
      try {
        // First approach - try to use getExternalStorageDirectory
        final output = await getExternalStorageDirectory();
        
        if (output == null) {
          throw Exception("External storage not available");
        }
        
        // Ensure directory exists
        if (!await Directory(output.path).exists()) {
          await Directory(output.path).create(recursive: true);
        }
        
        final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final filePath = '${output.path}/sales_report_$dateStr.xlsx';
        
        final file = File(filePath);
        
        var fileBytes = excel.encode();
        if (fileBytes != null) {
          await file.writeAsBytes(fileBytes);
          return filePath;
        } else {
          throw Exception("Failed to encode Excel file");
        }
      } catch (e) {
        
        // Second approach - try with application documents directory
        try {
          final appDocDir = await getApplicationDocumentsDirectory();
          
          final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          final filePath = '${appDocDir.path}/sales_report_$dateStr.xlsx';
          
          final file = File(filePath);
          
          var fileBytes = excel.encode();
          if (fileBytes != null) {
            await file.writeAsBytes(fileBytes);
            return filePath;
          } else {
            throw Exception("Failed to encode Excel file in alternative location");
          }
        } catch (e2) {
          throw Exception("Could not save Excel file: $e, $e2");
        }
      }
    } catch (e) {
      if (e is Error) {
      }
      return null;
    }
  }
}