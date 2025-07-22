import 'package:appp/AuthWidget/widget.dart';
import 'package:flutter/material.dart';

class PhoneAuthPage extends StatefulWidget {
  final TextEditingController phonenumber = TextEditingController();
  PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Center(
          child: Text("Phone Auth!", style: TextStyle(color: Colors.blueGrey)),
        ),
        backgroundColor: const Color.fromARGB(167, 14, 14, 14),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextSpace(
              ctrl: widget.phonenumber,
              icon: Icons.phone,
              placeholder: "Phone",
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Navigator.pushNamed(context, '/otpPage');
                // if (!formKey.currentState!.validate()) return;
                // await createUserWithEmailAndPassword();
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(234, 22, 22, 22),
                elevation: 20,
                foregroundColor: const Color.fromARGB(197, 100, 100, 100),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text("Send OTP", style: TextStyle(fontSize: 20)),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("New User?", style: TextStyle(color: Colors.grey[400])),
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
          ],
        ),
      ),
    );
  }
}
