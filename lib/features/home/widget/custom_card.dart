
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
            color: AppColor.tertiaryLightColor,
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
                 ),
                child: Icon(
                  icon,
                  size: 30,
                  color: AppColor.iconSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textprimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}