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
      {required String text, required Color color, required VoidCallback fun}) {
    return Padding(
      padding: const EdgeInsets.only(top: 26.0, left: 50, right: 50),
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
    return Scaffold(
      backgroundColor: primaryBgColor,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: SizedBox(
                  height: 160.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0.0),
                child: Text(
                  'My Shire',
                  style: TextStyle(
                    fontSize: 25.0,
                    color: primaryTextColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 60.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    'My Shire',
                    style: TextStyle(
                      fontSize: 45.0,
                      color: primaryTextColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
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
            // _createButton(
            //   text: 'Register',
            //   color: colorTwo,
            //   fun: () {
            //     setState(() {
            //       changeTheme();
            //     });
            //     ;
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (MediaQuery.sizeOf(context).width >
            MediaQuery.sizeOf(context).height)
        ? _landscapeMode(context)
        : _portraitMode(context);
  }
}
