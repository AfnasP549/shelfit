import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/splash/splash_screen.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
