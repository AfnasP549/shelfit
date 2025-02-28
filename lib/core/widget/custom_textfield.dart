// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:shelfit/core/color/color.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String name;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final TextInputType inputType;
  final String? Function(String?)? validator;
  final Color? inputTextColor; // Add this line

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.name,
    this.prefixIcon,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    required this.inputType,
    this.suffixIcon,
    this.validator,
    this.inputTextColor, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        maxLength: 32,
        maxLines: 1,
        keyboardType: inputType,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: inputTextColor ?? AppColor.textprimaryColor, // Use inputTextColor
          fontSize: 16,
        ),
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon, size: 24, color: AppColor.texttertiaryColor),
          suffixIcon: Icon(suffixIcon),
          isDense: true,
          labelText: name,
          counterText: '',
          labelStyle: const TextStyle(color: AppColor.texttertiaryColor),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.textfieldborder),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.iconColor),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.textfieldborder),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.errorColor),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.errorColor),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
    );
  }
}
