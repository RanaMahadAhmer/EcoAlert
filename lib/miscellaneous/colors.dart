import 'package:flutter/material.dart';

Color primaryBgColor = Colors.white;
Color primaryTextColor = Colors.black54;
Color colorOne = const Color.fromARGB(255, 2, 253, 177);
Color colorTwo = const Color.fromARGB(255, 253, 125, 182);
bool _darkMode = false;

void changeTheme() {
  if (!_darkMode) {
    _turnDarkMode();
    _darkMode = true;
  } else {
    _turnLightMode();
    _darkMode = false;
  }
}

void _turnLightMode() {
  primaryBgColor = Colors.white;
  primaryTextColor = Colors.black54;
  colorOne = const Color.fromARGB(255, 2, 253, 177);
  colorTwo = const Color.fromARGB(255, 253, 125, 182);
}

void _turnDarkMode() {
  primaryBgColor = Colors.black12;
  primaryTextColor = Colors.white;
  colorOne = const Color.fromARGB(200, 2, 253, 177);
  colorTwo = const Color.fromARGB(200, 253, 125, 182);
}
