

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/home/view/home_screen.dart';
import 'package:shelfit/features/inventory_item/view/inventory_screen.dart';
import 'package:shelfit/features/report/view/report_screen.dart';
import 'package:shelfit/features/sales/view/sales_screen.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key,});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  
  int _currentIndex = 0;

  final List<Widget> screens = [
     HomeScreen(),
     InventoryScreen(),
     SalesHistoryScreen(),
     ReportScreen(),
   
    
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      //backgroundColor: Colors.white,
      body: screens[_currentIndex],
      bottomNavigationBar: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Container(
                height: 60,
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                decoration: BoxDecoration(
                  color: AppColor.bottomprimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GNav(
                    gap: 8,
                    backgroundColor:  AppColor.secondryColor,
                    color:  AppColor.bottomIconSecondary,
                    activeColor: AppColor.bottomIconPrimary,
                    tabBackgroundColor:  AppColor.bottomsecondry,
                    padding: const EdgeInsets.all(1),
                    onTabChange: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    tabs: const [
                       GButton(
                        icon: Icons.home_outlined,iconSize: 32,
                        text: 'Home',
                      ),
                      GButton(
                        icon: Icons.inventory,iconSize: 30,
                        text: 'Product',
                      ),
                     
                      GButton(
                        icon: Icons.bar_chart,iconSize:  32,
                        text: 'Sales',
                      ),
                      GButton(
                        icon: Icons.report, iconSize: 32,
                        text: 'Report',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
