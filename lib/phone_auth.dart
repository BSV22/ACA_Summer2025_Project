import 'package:appp/AuthWidget/otpdialog.dart';
import 'package:appp/AuthWidget/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneAuthPage extends StatefulWidget {
  final TextEditingController phonenumber = TextEditingController();
  final formKey = GlobalKey<FormState>();
  PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  Future<void> phoneSignIn(BuildContext context, String phonenumber) async {
    TextEditingController codecontroller = TextEditingController();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91$phonenumber",
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phone number verified successfully')),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phone number verification failed: ${e.message}'),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        // Navigator.pushNamed(context, '/otpPage', arguments: {
        //   'verificationId': verificationId,
        //   'phoneNumber': widget.phonenumber.text.trim(),
        // });
        showOtpDialog(
          context,
          widget.phonenumber.text.trim(),
          codecontroller,
          () async {
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: codecontroller.text.trim(),
            );
            await FirebaseAuth.instance.signInWithCredential(credential);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Phone number verified successfully')),
            );
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/home');
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // This callback is called when the code auto-retrieval times out.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Code auto-retrieval timed out')),
        );
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Phone number verification initiated')),
    );
  }

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
      body: Form(
        key: widget.formKey,
        child: Center(
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
                  // Navigator.pushNamed(context, '/otpPage');
                  if (!widget.formKey.currentState!.validate()) return;
                  await phoneSignIn(context, widget.phonenumber.text.trim());
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
      ),
    );
  }
}
