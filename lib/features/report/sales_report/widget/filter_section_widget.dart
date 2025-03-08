import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/report/sales_report/controller/sales_report_controller.dart';

class FilterSectionWidget extends StatelessWidget {
  final SalesReportController controller;

  const FilterSectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: AppColor.secondryColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Sales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.textsecondryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() => InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: controller.startDate.value ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        controller.setStartDate(picked);
                      }
                    },
                    child: _buildDateContainer(
                      label: controller.startDate.value == null
                          ? 'Start Date'
                          : DateFormat('MMM dd, yyyy').format(controller.startDate.value!),
                    ),
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: controller.endDate.value ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        controller.setEndDate(picked);
                      }
                    },
                    child: _buildDateContainer(
                      label: controller.endDate.value == null
                          ? 'End Date'
                          : DateFormat('MMM dd, yyyy').format(controller.endDate.value!),
                    ),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: controller.resetFilters,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Filters'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateContainer({required String label}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.textfieldborder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: label == 'Start Date' || label == 'End Date' ? Colors.grey : AppColor.textsecondryColor,
            ),
          ),
          const Icon(Icons.calendar_today, size: 16),
        ],
      ),
    );
  }
}
