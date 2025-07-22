import 'package:flutter/material.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Center(
          child: Text(
            "OTP Verification",
            style: TextStyle(color: Colors.blueGrey),
          ),
        ),
        backgroundColor: const Color.fromARGB(167, 14, 14, 14),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the OTP sent to your phone",
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 322,
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_rounded),
                  prefixIconColor: Colors.red,
                  filled: true,
                  fillColor: const Color.fromARGB(255, 24, 24, 24),
                  hint: Text("OTP", style: TextStyle(color: Colors.grey)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color.fromARGB(200, 90, 90, 90),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color.fromARGB(200, 90, 90, 90),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle OTP verification logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(234, 22, 22, 22),
                elevation: 20,
                foregroundColor: const Color.fromARGB(197, 100, 100, 100),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text("Verify OTP", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
