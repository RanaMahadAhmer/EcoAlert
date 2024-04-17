import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../screens/login_screen.dart';
import '../../screens/registration/user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../miscellaneous/colors.dart';
import '../../miscellaneous/formatters/name_formatter.dart';

class DemographicRegistration extends StatefulWidget {
  const DemographicRegistration({super.key});
  static const String id = 'Demographic_Screen';
  @override
  State<DemographicRegistration> createState() =>
      _DemographicRegistrationState();
}

class _DemographicRegistrationState extends State<DemographicRegistration> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Widget errorCode = const Text('');

  void _setErrorCode({required String msg}) {
    setState(() {
      errorCode = Text(msg);
    });

    // Reset the message after 3 seconds
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        errorCode = const Text("");
      });
    });
  }

  _createInputField(
      {required String hint,
      required Function(String) fun,
      List<TextInputFormatter>? formatter}) {
    return TextField(
      style: const TextStyle(color: Colors.black87),
      textAlign: TextAlign.center,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              hint: 'Country',
              fun: (value) {
                UserInformation.country = value;
              },
              formatter: [
                NameFormatter(),
              ],
            ),
            const SizedBox(
              height: 8.0,
            ),
            _createInputField(
              hint: 'City',
              fun: (value) {
                UserInformation.city = value;
              },
              formatter: [
                NameFormatter(),
              ],
            ),
            const SizedBox(
              height: 8.0,
            ),
            _createInputField(
              hint: 'Town',
              fun: (value) {
                UserInformation.town = value;
              },
            ),
            const SizedBox(
              height: 8.0,
            ),
            _createInputField(
              hint: 'Street - House No',
              fun: (value) {
                UserInformation.street = value;
              },
            ),
            const SizedBox(
              height: 8.0,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 100),
              child: Material(
                color: colorTwo,
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                elevation: 5.0,
                child: MaterialButton(
                  onPressed: () async {
                    if (UserInformation.country != null &&
                        UserInformation.city != null &&
                        UserInformation.town != null &&
                        UserInformation.street != null) {
                      try {
                        setState(() {
                          errorCode = LoadingAnimationWidget.inkDrop(
                            color: const Color.fromARGB(255, 66, 104, 250),
                            size: 35,
                          );
                        });

                        await _auth.createUserWithEmailAndPassword(
                            email: UserInformation.userEmail!,
                            password: UserInformation.userPassword!);
                        await _firestore
                            .collection('userData')
                            .doc(UserInformation.userEmail)
                            .set(
                          {
                            'name': UserInformation.userName,
                            'password': UserInformation.userPassword,
                            'city': UserInformation.city,
                            'contact': UserInformation.userContact,
                            'country': UserInformation.country,
                            'streetHouse': UserInformation.street,
                            'town': UserInformation.town,
                          },
                        );

                        var userDocRef = _firestore.collection('serviceAreas').doc(
                            '${UserInformation.country}_${UserInformation.city}_${UserInformation.town}');
                        var doc = await userDocRef.get();
                        if (!doc.exists) {
                          await _firestore
                              .collection('serviceAreas')
                              .doc(
                                  '${UserInformation.country}_${UserInformation.city}_${UserInformation.town}')
                              .set(
                            {
                              'active': false,
                            },
                          );
                        }

                        setState(() {
                          errorCode = const Text('');
                        });

                        Navigator.pushNamed(context, LoginScreen.id);
                      } catch (e) {}
                    } else {
                      _setErrorCode(msg: "Please Fill All Fields Correctly");
                    }
                  },
                  minWidth: 200.0,
                  height: 52.0,
                  child: const Text(
                    'Register',
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
