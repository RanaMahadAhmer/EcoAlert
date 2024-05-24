import 'package:flutter/material.dart';
import 'colors.dart';

Widget buildLogo({required double height}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Hero(
        tag: 'logo',
        child: SizedBox(
          height: height,
          child: Image.asset('images/logo.png'),
        ),
      ),
      Text(
        'Eco Alert',
        style: TextStyle(
          fontSize: 25.0,
          color: primaryTextColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}
