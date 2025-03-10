// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/auth/service/auth_service.dart';
import 'package:shelfit/features/auth/view/signin_screen.dart';

class SignOutConfirmation {
  static final _auth = AuthService();

  static void showSignOutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?',style: TextStyle(color: AppColor.primaryColor),),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _auth.signout();
              Get.back();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SigninScreen()),
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
