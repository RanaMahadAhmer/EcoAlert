import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../miscellaneous/colors.dart';
import 'dashboard/dashboard_screen.dart';
import 'registration/user_info.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String id = 'Login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late UserCredential user;

  Widget errorCode = const Text('');

  void _setErrorCode({required String msg, required int time}) {
    setState(() {
      errorCode = Text(msg);
    });

    // Reset the message after 3 seconds
    Future.delayed(Duration(seconds: time), () {
      setState(() {
        errorCode = const Text("");
      });
    });
  }

  _createInputField(
      {required String hint,
      required Function(String) fun,
      TextInputType? keyboard,
      bool textHidden = false,
      List<TextInputFormatter>? formatter}) {
    return TextField(
      style: TextStyle(color: primaryTextColor),
      obscureText: textHidden,
      textAlign: TextAlign.center,
      keyboardType: keyboard,
      onChanged: fun,
      inputFormatters: formatter,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.lightBlue),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
      ),
    );
  }

  _createButton(
      {required String text,
      required Color color,
      double bottom = 0,
      required VoidCallback fun}) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: bottom, left: 100, right: 100),
      child: Material(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(30.0)),
        elevation: 5.0,
        child: MaterialButton(
          onPressed: fun,
          minWidth: 100.0,
          height: 52.0,
          child: Text(
            text,
          ),
        ),
      ),
    );
  }

  _logIn() {
    return () async {
      try {
        setState(() {
          errorCode = LoadingAnimationWidget.inkDrop(
            color: const Color.fromARGB(255, 66, 104, 250),
            size: 35,
          );
        });
        user = await _auth.signInWithEmailAndPassword(
            email: UserInformation.userEmail!,
            password: UserInformation.userPassword!);

        await _firestore
            .collection('userData')
            .doc('${UserInformation.userEmail}')
            .get()
            .then((value) async {
          var map = value.data() as Map<String, dynamic>;
          UserInformation.country = map['country'];
          UserInformation.city = map['city'];
          UserInformation.town = map['town'];
          UserInformation.street = map['streetHouse'];
          UserInformation.userContact = map['contact'];
          UserInformation.userName = map['name'];
        });

        var serviceAvailable = _firestore
            .collection('serviceAreas')
            .doc(
                '${UserInformation.country}_${UserInformation.city}_${UserInformation.town}')
            .get();
        serviceAvailable.then((value) {
          if (!value.data()!['active']) {
            setState(() {
              errorCode = const Text('Service Not Available In Your Area Yet');
            });
          } else {
            setState(() {
              errorCode = const Text('');
            });
            Navigator.pushNamed(context, DashboardScreen.id);
          }
        });
      } catch (e) {
        var error = e.toString();

        if (error.contains('[')) {
          switch (error.split(' ')[0]) {
            case '[firebase_auth/invalid-email]':
              _setErrorCode(msg: 'Email is Not Valid', time: 2);
              break;
            case '[firebase_auth/missing-email]':
              _setErrorCode(msg: 'Email is Empty', time: 2);
              break;
            case '[firebase_auth/invalid-login-credentials]':
              _setErrorCode(msg: 'Wrong Email/Password', time: 2);
              break;
            case '[firebase_auth/network-request-failed]':
              _setErrorCode(msg: 'No Internet', time: 2);
              break;
            case '[firebase_auth/too-many-requests]':
              _setErrorCode(
                  msg: 'Too Many Attempts Try Later Or Reset Password',
                  time: 2);
              break;
          }
        }
      }
    };
  }

  _resetAccount() {
    return () async {
      try {
        await _auth.sendPasswordResetEmail(email: UserInformation.userEmail!);
        _setErrorCode(msg: 'Email Sent Successfully', time: 2);
      } catch (e) {
        var error = e.toString();
        if (error.contains('[')) {
          switch (error.split(' ')[0]) {
            case '[firebase_auth/invalid-email]':
              _setErrorCode(msg: 'Email is Not Valid', time: 2);
              break;
            case '[firebase_auth/missing-email]':
              _setErrorCode(msg: 'Email is Empty', time: 2);
              break;
          }
        } else {
          _setErrorCode(msg: 'Email is Empty', time: 2);
        }
      }
    };
  }

  Widget _landscapeMode(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBgColor,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            children: [
              const SizedBox(
                height: 28.0,
              ),
              Hero(
                tag: 'logo',
                child: SizedBox(
                  height: 150.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
            ],
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ColoredBox(
                color: Colors.black,
                child: SizedBox(
                  height: 100,
                  width: 100,
                ),
              ),
              // _createInputField(
              //   hint: 'Email Address',
              //   fun: (value) {
              //     UserInformation.userEmail = value.toLowerCase();
              //   },
              //   keyboard: TextInputType.emailAddress,
              // ),
              // _createInputField(
              //   hint: 'Password',
              //   fun: (value) {
              //     UserInformation.userPassword = value;
              //   },
              //   textHidden: true,
              // ),
              // _createButton(text: 'Log In', color: colorOne, fun: _logIn()),
              // _createButton(
              //     text: 'Reset',
              //     color: colorTwo,
              //     bottom: 20,
              //     fun: _resetAccount()),
              // // Center(
              // //   child: errorCode,
              // // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _portraitMode(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBgColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(
              height: 28.0,
            ),
            Hero(
              tag: 'logo',
              child: SizedBox(
                height: 150.0,
                child: Image.asset('images/logo.png'),
              ),
            ),
            const SizedBox(
              height: 28.0,
            ),
            _createInputField(
              hint: 'Email Address',
              fun: (value) {
                UserInformation.userEmail = value.toLowerCase();
              },
              keyboard: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 8.0,
            ),
            _createInputField(
              hint: 'Password',
              fun: (value) {
                UserInformation.userPassword = value;
              },
              textHidden: true,
            ),
            const SizedBox(
              height: 8.0,
            ),
            _createButton(text: 'Log In', color: colorOne, fun: _logIn()),
            _createButton(
                text: 'Reset',
                color: colorTwo,
                bottom: 20,
                fun: _resetAccount()),
            Center(
              child: errorCode,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _landscapeMode(context);
  }
}
