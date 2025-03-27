import 'package:flutter/material.dart';
import 'package:shelfit/core/color/color.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.borderPrimary),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onRemove,
            icon: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: AppColor.borderSecondary),
                    borderRadius: BorderRadius.circular(100)),
                child: const Icon(
                  Icons.remove,
                  color: AppColor.iconPrimay,
                  size: 18,
                )),
          ),
          Text(
            'Quantity : ${quantity.toString()}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.textsecondryColor),
          ),
          IconButton(
            onPressed: onAdd,
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.borderSecondary),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(Icons.add,color:  AppColor.iconPrimay, size: 18,)),
          ),
        ],
      ),
    );
  }
}
