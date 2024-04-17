import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 10.0,
            ),
            Hero(
              tag: 'logo',
              child: SizedBox(
                height: 100.0,
                child: Image.asset('images/logo.png'),
              ),
            ),
            const SizedBox(
              height: 28.0,
            ),
            _createInputField(
              hint: 'Email Address',
              fun: (value) {
                UserInformation.userEmail = value;
              },
            ),
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
                  onPressed: () async {
                    if (UserInformation.userContact != null &&
                        UserInformation.userName != null &&
                        UserInformation.userPassword!.length >= 6 &&
                        UserInformation.userContact!.length == 15) {
                      try {
                        setState(() {
                          errorCode = LoadingAnimationWidget.inkDrop(
                            color: const Color.fromARGB(255, 66, 104, 250),
                            size: 35,
                          );
                        });

                        user = await _auth.createUserWithEmailAndPassword(
                            email: UserInformation.userEmail!,
                            password: UserInformation.userPassword!);
                        _auth.currentUser?.delete();
                        _showWarning(msg: '');
                        Navigator.pushNamed(
                            context, DemographicRegistration.id);
                      } catch (e) {
                        var errorCode = e.toString();
                        if (errorCode.contains('[')) {
                          switch (errorCode.split(' ')[0]) {
                            case '[firebase_auth/email-already-in-use]':
                              _showWarning(msg: 'Email Already in Use');
                              break;
                            case '[firebase_auth/invalid-email]':
                              _showWarning(msg: 'Email is Not Valid');
                              break;
                            case '[firebase_auth/missing-email]':
                              _showWarning(msg: 'Email is Empty');
                              break;
                          }
                        } else {
                          _showWarning(msg: 'Email/Password is Empty');
                        }
                      }
                    } else {
                      _showWarning(
                          msg:
                              "Please Fill Fields Correctly (Password Min 7 Chars)");
                    }
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
      ),
    );
  }
}
