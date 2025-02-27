import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shelfit/features/auth/view/signin_screen.dart';
import 'package:shelfit/features/home/home_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot){
            if(snapshot.connectionState==ConnectionState.waiting){
            return  Center(child:  Lottie.asset('asset/loading.json'));
          }else if(snapshot.hasError){
            return const Center(child: Text('Error'),);
          }
          else{
             if(snapshot.data ==  null){
              return const SigninScreen();
            }else{
              return HomeScreen();
            }
            // else{
            //   return  CustomNavBar();
            // }
          }
        },
        ),
    );
  }
}