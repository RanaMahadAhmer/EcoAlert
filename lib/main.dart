import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'miscellaneous/notification_api.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/registration/demographic_registration.dart';
import 'miscellaneous/messaging_api.dart';
import 'miscellaneous/firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/registration/profile_registration.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  NotificationApi.init();
  runApp(const EcoAlert());
}

class EcoAlert extends StatelessWidget {
  const EcoAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Alert',
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        ProfileRegistration.id: (context) => const ProfileRegistration(),
        DashboardScreen.id: (context) => const DashboardScreen(),
        DemographicRegistration.id: (context) =>
            const DemographicRegistration(),
      },
      debugShowCheckedModeBanner: true,
    );
  }
}
