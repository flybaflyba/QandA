import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:qanda/models/UserInformation.dart';
import 'package:qanda/universals/UniversalFunctions.dart';
import 'package:qanda/universals/UniversalValues.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SignInUpPage extends StatefulWidget{

  @override
  _SignInUpPageState createState() => _SignInUpPageState();
}

class _SignInUpPageState extends State<SignInUpPage> {

  Duration get animationTime => Duration(milliseconds: 2000);

  var pushToHome = true;

  String messageCode(String s) {
    if(kIsWeb) {
      UniversalFunctions.showToast(s, UniversalValues.toastMessageTypeWarningColor);
      pushToHome = false;
      return null;
    } else {
      return s;
    }
  }

  @override
  void initState() {
    super.initState();

    if(FirebaseAuth.instance.currentUser != null) {
      // Navigator.pop(context);
      // Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPage(),));
      print("user is logged in");
    }

  }

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
          // UserInformation userInformation = new UserInformation(email: userCredential.user.email);
          // userInformation.get(); // save user info to shared preference

          UserInformation userInformation = new UserInformation(email: FirebaseAuth.instance.currentUser.email);
          userInformation.get()
              .then((value) async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var userName = prefs.getString("userName");
            if(userName == null || userName == "") {
              print("missing user name from database");
            } else {
              print("user name is not saved locally but get from database");
            }
          });

          if (!FirebaseAuth.instance.currentUser.emailVerified) {
            try {
              await FirebaseAuth.instance.currentUser.sendEmailVerification();
            } on FirebaseAuthException catch (e) {
              return messageCode('Something went wrong. ${e.message}');
              return "Something went wrong. ${e.message}";
            } catch (e) {
              print(e);
            }
            FirebaseAuth.instance.signOut();
            return messageCode('Email not verified. Please check your inbox to verify.');
            return "Email not verified. Please check your inbox to verify.";
          } else {
            // return null;
          }

        }

      } on FirebaseAuthException catch (e) {
        print(e);
        if (e.code == 'user-not-found') {
          print('No user found');
          return messageCode('No user found');
          // return 'No user found';
        } else if (e.code == 'wrong-password') {
          print('Wrong password');
          return messageCode('Wrong password');
          return 'Wrong password';
        } else if (e.code == 'invalid-email') {
          print('Invalid email');
          return messageCode('Invalid email');
          return 'Invalid email';
        } else {
          print('Something went wrong');
          return messageCode('Something went wrong');
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

      if(!data.name.contains("byuh.edu")) {
        return messageCode('Please use your BYU-H email.');
        return "Please use your BYU-H email.";
      } else {
        try {
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: data.name,
            password: data.password,
          );
          print(userCredential);
          // we can use this to set some simple user inf
          // userCredential.user.updateProfile(displayName: 'Litian', photoURL: 'www.litianzhang.com');

          // create a user information document in database
          UserInformation userInformation = UserInformation(email: data.name);
          userInformation.create();

          userInformation.get()
              .then((value) async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var userName = prefs.getString("userName");
            if(userName == null || userName == "") {
              print("missing user name from database");
            } else {
              print("user name is not saved locally but get from database");
            }
          });

          if (!FirebaseAuth.instance.currentUser.emailVerified) {
            try {
              await FirebaseAuth.instance.currentUser.sendEmailVerification();
            } on FirebaseAuthException catch (e) {
              return messageCode('Something went wrong. ${e.message}');
              return "Something went wrong. ${e.message}";
            } catch (e) {
              print(e);
            }
            FirebaseAuth.instance.signOut();
            return messageCode('Please check your inbox to verify your email before log in.');
            return "Please check your inbox to verify your email before log in.";
          } else {
            // return null;
          }

        }
        on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            print('Password is too weak');
            return messageCode('Password is too weak');
            return 'Password is too weak';
          } else if (e.code == 'email-already-in-use') {
            print('Account exists');
            return messageCode('Account exists');
            return 'Account exists';
          } else if (e.code == 'invalid-email') {
            print('Invalid email');
            return messageCode('Invalid email');
            return 'Invalid email';
          }
        }
        catch (e) {
          print(e);
        }
        return null;
      }


    });
  }

  Future<String> recoverPassword(String email) {
    print('Name: $email');
    return Future.delayed(animationTime).then((_) async {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      }
      on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          return messageCode('User not found');
          return 'User not found';
        } else {
          return messageCode('Something went wrong');
          return 'Something went wrong';
        }
      }
      catch (e) {
        print(e);
      }
      return null;
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
        leading: BackButton(),
        actions: [
          Icon(Icons.add, color: UniversalValues.primaryColor,), //  to make the title center
        ],
        title: Center(
          child: Text(
            "Welcome to BYUH",
          ),
        )
      ),
      body: FlutterLogin(
        title: 'BYU Hawaii',
        logo: 'assets/images/logo.png',
        onLogin: signIn,
        onSignup: signUp,
        onSubmitAnimationCompleted: () {
          // if (!FirebaseAuth.instance.currentUser.emailVerified) {
          //   UniversalFunctions.showToast("Email not verified. Please check your inbox to verify.", UniversalValues.toastMessageTypeWarningColor);
          //   await FirebaseAuth.instance.currentUser.sendEmailVerification();
          //   FirebaseAuth.instance.signOut();
          // } else {
          Navigator.pop(context);
          // Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPage(),))

          UniversalFunctions.askForUserMissingInfo(context, true, "A couple more things");
          if(pushToHome) {
            UniversalFunctions.showToast("Your are logged in", UniversalValues.toastMessageTypeGoodColor);
          } else {
          }
          pushToHome = true;

          // }
          },
        onRecoverPassword: recoverPassword,
        // showDebugButtons: true,
        theme: LoginTheme(
          primaryColor: UniversalValues.primaryColor,
          buttonTheme: LoginButtonTheme(
            backgroundColor: UniversalValues.buttonColor,
          ),
        ),
        messages: LoginMessages(
          recoverPasswordDescription: "We will send you an email to reset your password.",
          // recoverPasswordButton: kIsWeb ? "" : "Forgot Password?",
          // forgotPasswordButton: kIsWeb ? "" : "Forgot Password?",
        ),
      ),
    );
  }

}

// master branch broken for some reason ...

// an error appears occasionally ...

// * What went wrong:
// Execution failed for task ':fluttertoast:compileDebugKotlin'.
// > Compilation error. See log for more details
