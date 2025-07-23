import 'package:appp/AuthWidget/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (!formKey.currentState!.validate()) return;

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome back, ${userCredential.user?.email}!')),
      );

      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An unexpected error occurred')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black87,
      // appBar: AppBar(
      //   title: Center(
      //     child: Text("Login!", style: TextStyle(color: Colors.blueGrey)),
      //   ),
      //   // backgroundColor: const Color.fromARGB(167, 14, 14, 14),
      // ),
      body: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_num, size: 100, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text("Welcome Back", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Login to manage your tickets", style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 20),
            EmailAuth(ctrl: emailController),
            Password(ctrl: passwordController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await loginUser();
              },

              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(290, 50),
                backgroundColor: Colors.blueAccent,
                elevation: 10,
                foregroundColor: const Color.fromARGB(197, 100, 100, 100),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text("Login", style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("New User?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text(
                    "SignUp here",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/phoneAuth');
              },
              child: Text(
                "Phone Auth",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
