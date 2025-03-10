import 'package:flutter/material.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/report/sales_report/controller/sales_report_controller.dart';

class ActionButtonsWidget extends StatelessWidget {
  final SalesReportController controller;
  
  const ActionButtonsWidget({super.key, required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColor.primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildShareMenu(context),
        ],
      ),
    );
  }

  Widget _buildShareMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Share Options',
      onSelected: (value) async {
        switch (value) {
          case 'view':
            await controller.viewPdf();
            break;
          case 'share':
            await controller.shareViaEmail();
            break;
          case 'print':
            await controller.printReport();
            break;
          case 'excel':
            await controller.shareExcelReport();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: ListTile(
            leading: Icon(Icons.visibility),
            title: Text('View PDF'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          child: ListTile(
            leading: Icon(Icons.share),
            title: Text('Share'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'print',
          child: ListTile(
            leading: Icon(Icons.print),
            title: Text('Print'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'excel',
          child: ListTile(
            leading: Icon(Icons.table_chart),
            title: Text('Excel'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}