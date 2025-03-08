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
        children: [
          Expanded(
            child: _buildElevatedButton(
              icon: Icons.visibility,
              label: 'View PDF',
              color: AppColor.successColor,
              onPressed: controller.viewPdf,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildElevatedButton(
              icon: Icons.share,
              label: 'Share',
              color: AppColor.successColor,
              onPressed: controller.shareViaEmail,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildElevatedButton(
              icon: Icons.print,
              label: 'Print',
              color: AppColor.successColor,
              onPressed: controller.printReport,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildElevatedButton(
              icon: Icons.table_chart,
              label: 'Excel',
              color: AppColor.successColor,
              onPressed: controller.shareExcelReport,
            ),
          ),
        ],
      ),
    );
  }

  // Private widget for reusable ElevatedButton
  Widget _buildElevatedButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
