import 'package:flutter/material.dart';
import './AuthWidget/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      FocusScope.of(context).unfocus();
      emailController.clear();
      passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User created: ${userCredential.user?.email}')),
      );
      Navigator.pushNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Signup failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black87,
      // appBar: AppBar(
      //   title: Center(
      //     child: Text("Sign Up!", style: TextStyle(color: Colors.blueGrey)),
      //   ),
      //   // TRY THIS: Try changing the color here to a specific color (to
      //   // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
      //   // change color while the other colors stay the same.
      //   backgroundColor: const Color.fromARGB(167, 14, 14, 14),
      // ),
      body: Form(
        key: formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.confirmation_num, size: 100, color: Colors.blueAccent),
              SizedBox(height: 20),
              Text(
                "Welcome",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "SignUp to create account",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              EmailAuth(ctrl: emailController),
              Password(ctrl: passwordController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  await createUserWithEmailAndPassword();
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
                child: Text(
                  "SignUp",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        "Login here",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
