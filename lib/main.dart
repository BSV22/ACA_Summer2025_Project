import 'package:appp/AuthWidget/otp_page.dart';
import 'package:appp/analytics_page.dart';
import 'package:appp/home.dart';
import 'package:appp/login_page.dart';
import 'package:appp/new_login_page.dart';
import 'package:appp/otp_page.dart';
import 'package:appp/phone_auth.dart';
import 'package:appp/qr_scanner.dart';
import 'package:appp/settings.dart';
import 'package:appp/sign_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/phoneAuth': (context) => PhoneAuthPage(),
        '/otpPage': (context) => OtpPage(),
        '/home': (context) => HomePage(),
        '/qrScanner': (context) => QrScanner(),
        '/settings': (context) => SettingsPage(),
        '/analytics': (context) => AnalyticsPage(),
        '/newLogin': (context) => NewLoginPage(),
        // '/newotpPage': (context) => OTPPage(),
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return NewLoginPage  ();
        },
      ),
    );
  }
}
