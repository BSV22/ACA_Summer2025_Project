import 'package:flutter/material.dart';

void showOtpDialog(
  BuildContext context,
  String phoneNumber,
  TextEditingController otpController,
  VoidCallback onPressed,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('OTP Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('An OTP has been sent to $phoneNumber.'),
            TextField(
              controller: otpController,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                icon: Icon(Icons.lock),
              ),
              keyboardType: TextInputType.number,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(onPressed: onPressed, child: Text('Verify')),
          ],
        ),
      );
    },
  );
}
