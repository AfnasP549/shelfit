import 'package:flutter/material.dart';
import 'package:shelfit/core/constant/custom_navigator.dart';
import 'package:shelfit/core/widget/custom_appbar.dart';
import 'package:shelfit/features/customer/view/customer_screen.dart';
import 'package:shelfit/features/home/widget/custom_card.dart';
import 'package:shelfit/features/inventory_item/view/inventory_screen.dart';
import 'package:shelfit/features/inventory_item/widget/signout_confirmation.dart';
import 'package:shelfit/features/report/view/report_screen.dart';
import 'package:shelfit/features/sales/view/sales_add_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Home',
        actions: [
          IconButton(
              onPressed: () => SignOutConfirmation.showSignOutDialog(context),
              icon: Icon(Icons.logout_outlined))
        ],
      ),
       body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            CustomDashboardCard(
              icon: Icons.inventory,
              label: 'Product',
              isFirst: true,
              onTap: () {
                
                customNavigator(context, const InventoryScreen());
              },
            ),
            CustomDashboardCard(
              icon: Icons.person_outline_outlined,
              label: 'Customer',
              onTap: () {
               customNavigator(context, CustomerScreen());
              },
            ),
            CustomDashboardCard(
              icon: Icons.business,
              label: 'Sales',
              onTap: () {
               customNavigator(context, SalesAddScreen());
              },
            ),
            CustomDashboardCard(
              icon: Icons.report,
              label: 'Report',
              onTap: () {
               customNavigator(context, ReportScreen());
              },
            ),
       
            
          ],
        ),
      ),
    );
  }
}