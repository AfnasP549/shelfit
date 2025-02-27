import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shelfit/core/color/color.dart';
import 'package:shelfit/core/constant/form_validation.dart';
import 'package:shelfit/core/widget/custom_button.dart';
import 'package:shelfit/core/widget/custom_textfield.dart';
import 'package:shelfit/features/auth/service/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final _auth = AuthService();


  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // bool _obscureText = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo
                  Image.asset('asset/shelf.png'),
                  const SizedBox(height: 24),

                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Text(
                    'Sign up to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColor.texttertiaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          //name field
                          CustomTextfield(
                            controller: _nameController,
                            name: 'Full Name',
                            inputType: TextInputType.text,
                            prefixIcon: Icons.person_outline,
                            validator: FormValidator.validateName,
                          ),
                          const SizedBox(height: 16),

                          //email field
                          CustomTextfield(
                            controller: _emailController,
                            name: 'Email',
                            inputType: TextInputType.text,
                            prefixIcon: Icons.email_outlined,
                            validator: FormValidator.validateEmail,
                          ),
                          const SizedBox(height: 16),

                          //pass
                          CustomTextfield(
                            controller: _passwordController,
                            name: 'Password',
                            inputType: TextInputType.text,
                            prefixIcon: Icons.lock_outline,
                            validator: FormValidator.validatePassword,
                          ),
                          const SizedBox(height: 24),

                          //signup btn
                          CustomButton(onTap: _signup, btnText: 'Sign Up'),
                          const SizedBox(height: 24),

                          // Login option
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account?'),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Sign In'),
                              ),
                            ],
                          ),
                        ],
                      ))
                ],
              )),
        ),
      ),
    );
  }

 _signup() async {
  if (_formKey.currentState!.validate()) {
    final user = await _auth.createUserWithEmailandPassword(
      _emailController.text, 
      _passwordController.text
    );
    if (user != null) {
      log('User created successfully');
    }
  } else {
    log('Form is not valid');
  }
}

}
