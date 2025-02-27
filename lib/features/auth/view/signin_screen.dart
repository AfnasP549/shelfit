import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/constant/form_validation.dart';
import 'package:shelfit/core/widget/custom_button.dart';
import 'package:shelfit/core/widget/custom_textfield.dart';
import 'package:shelfit/features/auth/service/auth_service.dart';
import 'package:shelfit/features/auth/view/signup_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<SigninScreen> {

  final _auth = AuthService();


  final _formKey = GlobalKey<FormState>();
  //final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              //app logo
              Image.asset('asset/shelf.png'), 
              SizedBox(height: 24),

              //create account text
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textprimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColor.texttertiaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              //form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    //email field
                    CustomTextfield(
                        controller: _emailController,
                        name: 'Email',
                        prefixIcon: Icons.person_outline,
                        inputType: TextInputType.emailAddress,
                      validator: FormValidator.validateEmail,
                        ),

                    //pass
                    CustomTextfield(
                      controller: _passwordController,
                      name: 'Password',
                      prefixIcon: Icons.lock_outline,
                      // suffixIcon: IconButton(onPressed: onPressed, icon: icon),
                      inputType: TextInputType.text,
                      obscureText: true,
                      validator: FormValidator.validatePassword,
                    ),
                    const SizedBox(height: 16),

                    //button
                    CustomButton(onTap: _signin, btnText: 'Sign in'),
                    const SizedBox(height: 24),

                    //signup option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> SignupScreen()));
                          },
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _signin() async {
  if (_formKey.currentState!.validate()) {
    final user = await _auth.signinUserWithEmailandPassword(
      _emailController.text, 
      _passwordController.text
    );
    if (user != null) {
      log('User signed in');
    }
  } else {
    log('Form is not valid');
  }
}

}
