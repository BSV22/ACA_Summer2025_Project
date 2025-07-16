import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginMaterialPage extends StatefulWidget {
  const LoginMaterialPage({super.key});

  @override
  State<LoginMaterialPage> createState() => _LoginMaterialPageState();
}

class _LoginMaterialPageState extends State<LoginMaterialPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? email;
  String? password;

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
    
    // Navigator.of(context).pushReplacementNamed('/home');
    
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Login failed')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An unexpected error occurred')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(
        color: const Color.fromARGB(200, 90, 90, 90),
        width: 1.5,
      ),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(246, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(225, 22, 22, 22),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),

        title: Center(
          child: Text(
            'Welcome Again !',
            style: TextStyle(
              fontSize: 30,
              color: const Color.fromARGB(212, 164, 165, 162),
            ),
          ),
        ),

        // flexibleSpace: Center(child: SafeArea(child: Text("Please login",style: TextStyle(color: Colors.red),),),),
      ),
      body: Form(
        key: formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container(padding: EdgeInsets.all(20), child: Text("User Name:", style: TextStyle(
              //     color: Colors.black54,
              //     fontWeight: FontWeight.w900,
              //     fontSize: 20
              // )),
              // ),
              Container(
                width: 300.0,
                padding: EdgeInsets.all(20),
                child: TextFormField(
                  style: TextStyle(
                    color: const Color.fromARGB(255, 119, 119, 119),
                  ),
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.account_circle_outlined),
                    prefixIconColor: const Color.fromARGB(255, 230, 13, 13),
                    filled: true,
                    fillColor: const Color.fromARGB(149, 32, 32, 32),
                    hintText: "Email :",
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(224, 151, 151, 151),
                      fontSize: 14.0,
                    ),
                    enabledBorder: border,
                    focusedBorder: border,
                    // label: Text("User Name")
                  ),
                ),
              ),
              Container(
                width: 300.0,
                padding: EdgeInsets.all(20),
                child: TextFormField(
                  style: TextStyle(
                    color: const Color.fromARGB(255, 119, 119, 119),
                  ),
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "Password must have at least 6 characters";
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password),
                    prefixIconColor: const Color.fromARGB(255, 255, 34, 34),
                    filled: true,
                    fillColor: const Color.fromARGB(149, 32, 32, 32),
                    hintText: "Password :",
                    // label: Text("Password"),
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(224, 151, 151, 151),
                      fontSize: 14.0,
                    ),
                    enabledBorder: border,
                    focusedBorder: border,
                  ),
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  await loginUser();
                  // email = emailController.text;
                  // password = passwordController.text;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(234, 22, 22, 22),
                  elevation: 20,
                  foregroundColor: const Color.fromARGB(197, 100, 100, 100),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text("Login", style: TextStyle(fontSize: 20)),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New User?",
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text(
                        "Signup here",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    
                  ],
                ),
              ),
            ],
          ),
          //  "Already have an account?","Login here",
        ),
      ),
    );
  }
}
