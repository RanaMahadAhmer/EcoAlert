import 'package:eco_alert/miscellaneous/formatters/email_formatter.dart';
import 'package:eco_alert/miscellaneous/logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
  List _entryBoxList = [];
  bool _isVisible = true;

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
      TextInputFormatter? formatter}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        style: const TextStyle(color: Colors.black87),
        obscureText: textHidden,
        textAlign: TextAlign.center,
        keyboardType: keyboard,
        onChanged: fun,
        obscuringCharacter: "*",
        onTap: () {
          if (hint == 'Password (Tap to See)') {
            setState(() {
              _isVisible = !_isVisible;
            });
          }
        },
        inputFormatters: <TextInputFormatter>[
          formatter ?? FilteringTextInputFormatter.deny('')
        ],
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
      ),
    );
  }

  _createNextButton() {
    return Material(
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
    );
  }

  Widget _portraitMode(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildLogo(height: 160),
                ..._entryBoxList,
                _createNextButton(),
                Center(child: errorCode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _landscapeMode(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
            child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Row(
            children: <Widget>[
              Expanded(
                child: buildLogo(height: 160),
              ),
              Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _entryBoxList[0],
                                const SizedBox(
                                  height: 8.0,
                                ),
                                _entryBoxList[1],
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _entryBoxList[2],
                                const SizedBox(
                                  height: 8.0,
                                ),
                                _entryBoxList[3],
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Column(
                        children: [
                          _createNextButton(),
                          Center(child: errorCode),
                        ],
                      )
                    ],
                  ))
            ],
          ),
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _entryBoxList = [
      _createInputField(
          hint: 'Email Address (XXX@XXX.XXX)',
          fun: (value) {
            UserInformation.userEmail = value;
          },
          formatter: EmailFormatter()),
      _createInputField(
          hint: 'Full Name',
          fun: (value) {
            UserInformation.userName = value;
          },
          formatter: NameFormatter()),
      _createInputField(
        hint: 'Contact Number (XXXXXXXXXXXX)',
        keyboard: TextInputType.phone,
        fun: (value) {
          UserInformation.userContact = value;
        },
        formatter: PhoneNumberFormatter(),
      ),
      _createInputField(
        hint: 'Password (Tap to See)',
        textHidden: _isVisible,
        fun: (value) {
          UserInformation.userPassword = value;
        },
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
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
