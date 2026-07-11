import 'package:appp/AuthWidget/otp_page.dart';
import 'package:appp/analytics_page.dart';
import 'package:appp/home.dart';
import 'package:appp/login_page.dart';
import 'package:appp/new_login_page.dart';
import 'package:appp/phone_auth.dart';
import 'package:appp/qr_scanner.dart';
import 'package:appp/settings.dart';
import 'package:appp/sign_up_page.dart';
import 'package:appp/start.dart';
import 'package:appp/tickets.dart';
import 'package:appp/add_ticket.dart';
import 'package:appp/rewards.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            primaryColor: Colors.blueAccent,
            scaffoldBackgroundColor: Colors.grey[100],
            cardTheme: const CardThemeData(color: Colors.white),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            primaryColor: Colors.blueAccent,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardTheme: const CardThemeData(color: Color(0xFF1E1E1E)),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
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
            '/tickets': (context) => const TicketsPage(),
            '/addTicket': (context) => const AddTicketPage(),
            '/rewards': (context) => const RewardsPage(),
          },
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return WelcomePage();
            },
          ),
        );
      },
    );
  }
}
