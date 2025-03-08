
import 'package:flutter/material.dart';
import 'package:shelfit/core/color/color.dart';

class CustomDashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isFirst;
  final VoidCallback? onTap;  // Added onTap callback

  const CustomDashboardCard({
    super.key,
    required this.icon,
    required this.label,
    this.isFirst = false,
    this.onTap,  
  });

  @override
  Widget build(BuildContext context) {
    return InkWell( 
      onTap: onTap,
      borderRadius: BorderRadius.circular(15), 
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.secondryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(196, 255, 255, 255),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: AppColor.iconprimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColor.textsecondryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}