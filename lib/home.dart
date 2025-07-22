import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Center(
          child: Text("Home Page", style: TextStyle(color: Colors.blueGrey)),
        ),
        backgroundColor: const Color.fromARGB(167, 14, 14, 14),
      ),
      body: Center(
        child: Text(
          'Welcome to the Home Page!',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}