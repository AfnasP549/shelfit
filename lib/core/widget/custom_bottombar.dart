

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/features/inventory_item/view/inventory_screen.dart';
import 'package:shelfit/features/inventory_item/view/add_item_screen.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key,});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  
  int _currentIndex = 0;

  final List<Widget> screens = [
     InventoryScreen(),
     InventoryScreen(),
     InventoryScreen(),
     InventoryScreen(),
   
    
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
                    backgroundColor:  AppColor.bottomprimary,
                    color:  AppColor.bottomtertiary,
                    activeColor: AppColor.bottomsecondry,
                    tabBackgroundColor:  AppColor.bottomprimary,
                    padding: const EdgeInsets.all(1),
                    onTabChange: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    tabs: const [
                      GButton(
                        icon: Icons.inventory_2_outlined,iconSize: 32,
                        text: 'Inventory',
                      ),
                      GButton(
                        icon: Icons.home_outlined,iconSize: 32,
                        text: 'Home',
                      ),
                      GButton(
                        icon: Icons.home_outlined,iconSize: 32,
                        text: 'Home',
                      ),
                      GButton(
                        icon: Icons.home_outlined,iconSize: 32,
                        text: 'Home',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 0),
        height: 64,
        width: 64,
        child: FloatingActionButton(
          backgroundColor: AppColor.primaryColor,
          elevation: 0,
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>AddItemScreen()));
          },
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 3, color: AppColor.bottomtertiary),
            borderRadius: BorderRadius.circular(100)
          ),
          child: Icon(Icons.add, color: AppColor.secondryColor, size: 30,),
          ),
      ),
    );
  }
}
