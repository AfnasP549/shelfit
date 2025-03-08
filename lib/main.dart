import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/instance_manager.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/customer/controller/customer_controller.dart';
import 'package:shelfit/features/inventory_item/controller/inventory_controller.dart';
import 'package:shelfit/features/report/sales_report/view/sales_report_screen.dart';
import 'package:shelfit/features/sales/controller/sales_controller.dart';
import 'package:shelfit/features/splash/splash_screen.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
Get.put(InventoryController());
Get.put(CustomerController());
Get.put(SalesController());
//Get.put(SalesReportScreen());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shelf it',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColor.primaryColor,
          appBarTheme: const AppBarTheme(
          backgroundColor: AppColor.primaryColor,
          foregroundColor: AppColor.textprimaryColor,
        ),
          textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColor.textprimaryColor),
          bodyMedium: TextStyle(color: AppColor.textprimaryColor),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.textprimaryColor,
            foregroundColor: AppColor.textsecondryColor,
          )
        ),
      
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
