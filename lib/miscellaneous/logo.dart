import 'package:flutter/material.dart';

Widget buildLogo({required double height}) {
  return Hero(
    tag: 'logo',
    child: SizedBox(
      height: height,
      child: Image.asset('images/logo.png'),
    ),
  );
}
