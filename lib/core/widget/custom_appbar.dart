// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:shelfit/core/color/color.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  const CustomAppbar({
    super.key,
    required this.title,
    this.leading,
     this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
     // width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.secondryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),

        )

      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(title,style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
        leading: leading,
        actions: actions,
      ),
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 40);
}
