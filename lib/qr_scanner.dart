import 'package:flutter/material.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State <QrScanner> createState() =>  QrScannerState();
}

class  QrScannerState extends State <QrScanner> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          'QR Scanner Placeholder',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}