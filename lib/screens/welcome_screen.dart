import 'package:eco_alert/miscellaneous/logo.dart';
import 'package:flutter/material.dart';
import '../miscellaneous/colors.dart';

import 'login_screen.dart';
import 'registration/profile_registration.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  static const String id = 'Welcome_screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  _createButton(
      {required String text,
      required Color color,
      required VoidCallback fun,
      double topPad = 26}) {
    return Padding(
      padding: EdgeInsets.only(top: topPad, left: 50, right: 50),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: fun,
          minWidth: 200.0,
          height: 52.0,
          child: Text(
            text,
          ),
        ),
      ),
    );
  }

  List<Widget> _logo() {
    return [
      buildLogo(height: 160),
      Padding(
        padding: const EdgeInsets.only(left: 0.0),
        child: Text(
          'Eco Alert',
          style: TextStyle(
            fontSize: 25.0,
            color: primaryTextColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      )
    ];
  }

  Widget _landscapeMode(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBgColor,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.center, children: _logo()),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _createButton(
                text: 'Log In',
                color: colorOne,
                topPad: 0,
                fun: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                },
              ),
              _createButton(
                text: 'Register',
                color: colorTwo,
                topPad: 26,
                fun: () {
                  Navigator.pushNamed(context, ProfileRegistration.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _portraitMode(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ..._logo(),
            _createButton(
              text: 'Log In',
              color: colorOne,
              fun: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            _createButton(
              text: 'Register',
              color: colorTwo,
              fun: () {
                Navigator.pushNamed(context, ProfileRegistration.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          (MediaQuery.sizeOf(context).width > MediaQuery.sizeOf(context).height)
              ? _landscapeMode(context)
              : _portraitMode(context),
    );
  }
}
