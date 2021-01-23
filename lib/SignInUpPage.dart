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

      return null;
    });
  }

  Future<String> signUp(LoginData data) {
    print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(animationTime).then((_) async {

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