import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:qanda/MenuPage.dart';
import 'package:qanda/UniversalValues.dart';

class SignInUpPage extends StatefulWidget{

  @override
  _SignInUpPageState createState() => _SignInUpPageState();
}

class _SignInUpPageState extends State<SignInUpPage> {

  Duration get animationTime => Duration(milliseconds: 2000);

  Future<String> signIn(LoginData data) {
    print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(animationTime).then((_) async {

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: data.name,
            password: data.password
        );

        print(userCredential);
        if(userCredential != null) {
          print("I'm signing in!!!");
        }

      } on FirebaseAuthException catch (e) {
        print(e);
        if (e.code == 'user-not-found') {
          print('No user found');
          return 'No user found';
        } else if (e.code == 'wrong-password') {
          print('Wrong password');
          return 'Wrong password';
        } else if (e.code == 'invalid-email') {
          print('Invalid email');
          return 'Invalid email';
        } else {
          print('Something went wrong');
          return 'Something went wrong';
        }
      }
      catch (e) {
        print(e);
      }

      return null;
    });
  }

  Future<String> signUp(LoginData data) {
    print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(animationTime).then((_) async {

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: data.name,
          password: data.password,
        );
        print(userCredential);
        // we can use this to set some simple user info 
        // userCredential.user.updateProfile(displayName: 'Litian', photoURL: 'www.litianzhang.com');


      }
      on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('Password is too weak');
          return 'Password is too weak';
        } else if (e.code == 'email-already-in-use') {
          print('Account exists');
          return 'Account exists';
        } else if (e.code == 'invalid-email') {
          print('Invalid email');
          return 'Invalid email';
        }
      }
      catch (e) {
        print(e);
      }
      return null;
    });
  }

  Future<String> recoverPassword(String name) {
    print('Name: $name');
    return Future.delayed(animationTime).then((_) {

      return "You cannot reset your password";
      // return null;
    });
  }

  final inputBorder = BorderRadius.vertical(
    bottom: Radius.circular(10.0),
    top: Radius.circular(20.0),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Welcome to BYUH",
          ),
        )
      ),
      body: FlutterLogin(
        title: 'BYU Hawaii',
        logo: 'assets/images/byu_hawaii_medallion_logo.png',
        onLogin: signIn,
        onSignup: signUp,
        onSubmitAnimationCompleted: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPage(),));
        },
        onRecoverPassword: recoverPassword,
        // showDebugButtons: true,
        theme: LoginTheme(
          primaryColor: UniversalValues.primaryColor,
          buttonTheme: LoginButtonTheme(
            backgroundColor: UniversalValues.buttonColor,
          ),
        ),
      ),
    );
  }

}