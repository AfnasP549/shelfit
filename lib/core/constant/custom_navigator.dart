import 'package:flutter/material.dart';

customNavigator(BuildContext context, Widget screen){
  return Navigator.push(context, MaterialPageRoute(builder: (context)=>screen));
}