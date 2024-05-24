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

  Widget _landscapeMode(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        buildLogo(height: 160),
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
    );
  }

  Widget _portraitMode(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildLogo(height: 160),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return orientation == Orientation.portrait
              ? _portraitMode(context)
              : _landscapeMode(context);
        },
      ),
    );
  }
}
