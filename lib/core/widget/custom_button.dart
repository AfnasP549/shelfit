// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:shelfit/core/color/color.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final double? btnwidth;
  final double? btnheight;
  final String btnText;
  final Color? btnTextColor;
  final double? fontSize;
  final Color? btnColor;
  final IconData? btnIcon; // Optional icon

  const CustomButton({
    super.key,
    required this.onTap,
    this.btnwidth,
    this.btnheight,
    required this.btnText,
    this.btnTextColor,
    this.fontSize = 16,
    this.btnColor = AppColor.secondryColor,
    this.btnIcon, // Initialize optional icon
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(btnwidth ?? MediaQuery.of(context).size.width, 
                          btnheight ?? MediaQuery.of(context).size.height * 0.06),
        backgroundColor: btnColor,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (btnIcon != null) ...[
            Icon(btnIcon, color: btnTextColor),
            const SizedBox(width: 8), // Space between icon and text
          ],
          Text(
            btnText,
            style: TextStyle(fontSize: fontSize, color: btnTextColor),
          ),
        ],
      ),
    );
  }
}
