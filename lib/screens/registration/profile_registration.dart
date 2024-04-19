import 'package:eco_alert/miscellaneous/formatters/email_formatter.dart';
import 'package:eco_alert/miscellaneous/logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../miscellaneous/colors.dart';
import '../../miscellaneous/formatters/name_formatter.dart';
import 'demographic_registration.dart';

import '../../miscellaneous/formatters/phone_number_formatter.dart';
import 'user_info.dart';

class ProfileRegistration extends StatefulWidget {
  const ProfileRegistration({super.key});

  static const String id = 'Registration_screen';

  @override
  State<ProfileRegistration> createState() => _ProfileRegistrationState();
}

class _ProfileRegistrationState extends State<ProfileRegistration> {
  final _auth = FirebaseAuth.instance;
  late UserCredential user;
  Widget errorCode = const Text('');

  void _showWarning({required String msg}) {
    setState(() {
      errorCode = Text(msg);
    });
    Future.delayed(const Duration(seconds: 2), () {
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
      style: const TextStyle(color: Colors.black87),
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

  Widget _portraitMode(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 10.0,
          ),
          buildLogo(height: 100),
          const SizedBox(
            height: 28.0,
          ),
          _createInputField(
              hint: 'Email Address (XXX@XXX.XXX)',
              fun: (value) {
                UserInformation.userEmail = value;
              },
              formatter: [EmailFormatter()]),
          const SizedBox(
            height: 8.0,
          ),
          _createInputField(
            hint: 'Full Name',
            fun: (value) {
              UserInformation.userName = value;
            },
            formatter: [
              NameFormatter(),
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          _createInputField(
            hint: 'Contact Number (XXXXXXXXXXXX)',
            keyboard: TextInputType.phone,
            fun: (value) {
              UserInformation.userContact = value;
            },
            formatter: [
              PhoneNumberFormatter(),
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          _createInputField(
            hint: 'Password',
            textHidden: true,
            fun: (value) {
              UserInformation.userPassword = value;
            },
          ),
          const SizedBox(
            height: 24.0,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 100),
            child: Material(
              color: colorOne,
              borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              elevation: 5.0,
              child: MaterialButton(
                onPressed: () {
                  _showWarning(msg: "msg");
                },
                minWidth: 100.0,
                height: 52.0,
                child: const Text(
                  'Next',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Center(child: errorCode),
        ],
      ),
    );
  }

  Widget _landscapeMode(BuildContext context) {
    return Row(
      children: <Widget>[
        Column(
          children: [
            buildLogo(height: 160),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 200.0),
          child: Column(
            children: [
              _createInputField(
                hint: 'Email Address (XXX@XXX.XXX)',
                fun: (value) {
                  UserInformation.userEmail = value;
                },
                formatter: [EmailFormatter()],
              ),

              // _createInputField(
              //   hint: 'Full Name',
              //   fun: (value) {
              //     UserInformation.userName = value;
              //   },
              //   formatter: [
              //     NameFormatter()
              //   ],
              // ),
            ],
          ),
        ),
        // Column(
        //   children: [
        //     _createInputField(
        //       hint: 'Contact Number (XXXXXXXXXXXX)',
        //       keyboard: TextInputType.phone,
        //       fun: (value) {
        //         UserInformation.userContact = value;
        //       },
        //       formatter: [
        //         PhoneNumberFormatter(),
        //       ],
        //     ),
        //     _createInputField(
        //       hint: 'Password',
        //       textHidden: true,
        //       fun: (value) {
        //         UserInformation.userPassword = value;
        //       },
        //     ),
        //     Padding(
        //       padding:
        //           const EdgeInsets.symmetric(vertical: 16.0, horizontal: 100),
        //       child: Material(
        //         color: colorOne,
        //         borderRadius: const BorderRadius.all(Radius.circular(30.0)),
        //         elevation: 5.0,
        //         child: MaterialButton(
        //           onPressed: () {
        //             _showWarning(msg: "msg");
        //           },
        //           minWidth: 100.0,
        //           height: 52.0,
        //           child: const Text(
        //             'Next',
        //             style: TextStyle(color: Colors.white),
        //           ),
        //         ),
        //       ),
        //     ),
        //     Center(child: errorCode),
        //   ],
        // )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          (MediaQuery.sizeOf(context).width > MediaQuery.sizeOf(context).height)
              ? _landscapeMode(context)
              : _portraitMode(context),
    );
  }
}
