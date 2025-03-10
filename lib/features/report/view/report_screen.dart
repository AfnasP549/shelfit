import 'package:flutter/material.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/report/customer_report/view/customer_ledger_screen.dart';
import 'package:shelfit/features/report/item_report/view/inventory_report_screen.dart';
import 'package:shelfit/features/report/sales_report/view/sales_report_screen.dart';


class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          bottom: const TabBar(
            labelColor: AppColor.bottomsecondry,
            tabs: [
              Tab(text: 'Sales Report'),
              Tab(text: 'Item Report'),
              Tab(text: 'Customer Ledger'),
            ],
          ),
        ),
        body:  TabBarView(
          children: [
            SalesReportScreen(),
            InventoryReportScreen(),
            CustomerLedgerReportScreen()
          ],
        ),
      ),
    );
  }
}
