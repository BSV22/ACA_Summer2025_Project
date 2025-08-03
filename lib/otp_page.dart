import 'package:flutter/material.dart';

class OTPPage extends StatefulWidget {
  // final TextEditingController phonenumber = TextEditingController();
  // final TextEditingController otpctrl = TextEditingController();
  final String phonenumber;
  final TextEditingController otpctrl;
  final VoidCallback onVerify;
  const OTPPage({
    super.key,
    required this.phonenumber,
    required this.otpctrl,
    required this.onVerify,
  });
  // OTPPage({super.key});

  @override
  State<OTPPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OTPPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,

      body: Center(
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
                    color: Colors.blueAccent,
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
              "Enter OTP sent to ${widget.phonenumber}",
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            SizedBox(height: 20),
            Container(
              width: 322,
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
                maxLength: 6,
                controller: widget.otpctrl,
                keyboardType: TextInputType.text,
                textDirection: TextDirection.ltr,
                obscureText: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  prefixIconColor: Colors.white,
                  // counterText: "6 digits",
                  hint: Text(
                    "Enter OTP",
                    style: TextStyle(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  // prefixIcon: Icon(Icons.phone),
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),

            ElevatedButton(
              onPressed: widget.onVerify,

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
                "Verify OTP",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () => {Navigator.pushNamed(context, '/home')},
              child: Text(
                "Change Phone Number",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
