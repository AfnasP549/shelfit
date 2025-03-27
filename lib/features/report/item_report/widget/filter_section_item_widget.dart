import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/report/item_report/controller/inventory_report_controller.dart';

class FilterSectionItemWidget extends StatelessWidget {
  final InventoryReportController controller;

  const FilterSectionItemWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.primaryColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Date',
              style: TextStyle(
                color: AppColor.textprimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DatePickerField(
                    label: 'Start Date',
                    value: controller.startDate.value,
                    onSelect: (date) => controller.setStartDate(date),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DatePickerField(
                    label: 'End Date',
                    value: controller.endDate.value,
                    onSelect: (date) => controller.setEndDate(date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: controller.resetFilters,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Filters'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColor.textprimaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Date picker widget
class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final Function(DateTime?) onSelect;

  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColor.tertiaryColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onSelect(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: AppColor.primaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null
                  ? DateFormat('MMM dd, yyyy').format(value!)
                  : label,
              style: TextStyle(
                color: value != null ? Colors.black : Colors.grey.shade600,
              ),
            ),
            Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColor.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
