import 'package:appp/AuthWidget/otpdialog.dart';
import 'package:appp/AuthWidget/widget.dart';
import 'package:appp/otp_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewLoginPage extends StatefulWidget {
  final TextEditingController phonenumber = TextEditingController();
  final TextEditingController CouponCode = TextEditingController();

  final formKey = GlobalKey<FormState>();
  NewLoginPage({super.key});

  @override
  State<NewLoginPage> createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> {
  // Function to create user with email and password

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

        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OTPPage(
      phonenumber: phonenumber,
      otpctrl: codecontroller,
      onVerify: () async {
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: codecontroller.text.trim(),
            );
            await FirebaseAuth.instance.signInWithCredential(credential);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Phone number verified successfully')),
            );
            Navigator.of(context).pushReplacementNamed('/home');
          },
    ),
  ),
);


        // showOtpDialog(
        //   context,
        //   widget.phonenumber.text.trim(),
        //   codecontroller,
        //   () async {
        //     PhoneAuthCredential credential = PhoneAuthProvider.credential(
        //       verificationId: verificationId,
        //       smsCode: codecontroller.text.trim(),
        //     );
        //     await FirebaseAuth.instance.signInWithCredential(credential);
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(content: Text('Phone number verified successfully')),
        //     );
        //     Navigator.of(context).pop();
        //     Navigator.of(context).pushReplacementNamed('/home');
        //   },
        // );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // This callback is called when the code auto-retrieval times out.
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Code auto-retrieval timed out')),
        // );
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Phone number verification initiated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Form(
        key: widget.formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 290,
                // padding: EdgeInsets.all(16.0),
                // margin: EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.pool_rounded,
                      size: 100,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Welcome to AquaFun",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 10),
              Text(
                "Enter Your Phone Number to get started",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 20),
              Container(
                width: 322,
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: widget.phonenumber,
                  keyboardType: TextInputType.text,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    prefixIconColor: Colors.black,
                    fillColor: Colors.white,
                    filled: true,
                    hint: Text(
                      "Phone Number",
                      style: TextStyle(color: Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Container(
                width: 322,
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: widget.CouponCode,
                  keyboardType: TextInputType.text,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    prefixIconColor: Colors.black,
                    fillColor: Colors.white,
                    filled: true,
                    hint: Text(
                      "Referral Code (Optional)",
                      style: TextStyle(color: Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Icon(Icons.card_giftcard_rounded),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (!widget.formKey.currentState!.validate()) return;
                  await phoneSignIn(context, widget.phonenumber.text.trim());
                  // Navigator.pushNamed(context, '/newotpPage');
                },

                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(290, 50),
                  backgroundColor: Colors.white,
                  // elevation: 10,
                  foregroundColor: const Color.fromARGB(197, 100, 100, 100),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  "Send OTP",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
