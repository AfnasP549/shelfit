import 'dart:developer';


import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final _auth = FirebaseAuth.instance;

//!signUp
  Future<User?> createUserWithEmailandPassword(String email, String pass) async{
    try{
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
      return cred.user;
    } on FirebaseAuthException catch(e){
      exceptionHandler(e.code);
    }catch(e){
      log('Something went wrong');
    }
    return null;
  }

  //!signIn
    Future<User?> signinUserWithEmailandPassword(String email, String pass) async{
    try{
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: pass);
      return cred.user;
    } on FirebaseAuthException catch(e){
      exceptionHandler(e.code);
    }catch(e){
      log('Something went wrong');
    }
    return null;
  }

  //!signOut
  Future<void>signout()async{
    try{
    await _auth.signOut();
    }catch(e){
      log('Something went wrong');
    }
  }


//!Exception handler
void exceptionHandler(String code) {
  switch (code) {
    case "invalid-email":
      log('The email address is badly formatted.');
      break;
    case "user-not-found":
      log('No user found for this email.');
      break;
    case "wrong-password":
      log('Incorrect password. Please try again.');
      break;
    case "Weak-Password":
      log('Your Password must be at least 6 characters');
      break;
    case "email-already-in-use":
      log('User Already exists');
      break;
    default:
      log('Something went wrong');
  }
}

  
}
