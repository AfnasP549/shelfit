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
          bottom:  TabBar(
            labelColor: AppColor.bottomsecondry,
            tabs: [
              Container(
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(100),
                  color: AppColor.tertiaryColor
                ),
                padding: EdgeInsets.all(4),
                child: Tab(text: 'Sales Report')),


              Container(
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(100),
                  color: AppColor.tertiaryColor
                ),
                padding: EdgeInsets.all(4),
                child:  Tab(text: 'Item Report'),),


              Container(
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(100),
                  color: AppColor.tertiaryColor
                ),
                padding: EdgeInsets.all(4),
                child:   Tab(text: 'Customer Ledger')),
             
             
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
