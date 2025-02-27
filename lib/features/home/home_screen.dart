import 'package:flutter/material.dart';
import 'package:shelfit/core/widget/custom_appbar.dart';
import 'package:shelfit/features/auth/service/auth_service.dart';
import 'package:shelfit/features/auth/view/signin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Home',
        actions: [
          IconButton(onPressed: _signout, icon: Icon(Icons.logout_outlined))
        ],
        ),
    );
  }
  _signout()async{
    await _auth.signout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SigninScreen()));
  }
}