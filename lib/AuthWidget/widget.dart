import 'package:flutter/material.dart';

class Password extends StatelessWidget {
  const Password({super.key, required this.ctrl});

  final dynamic ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 322,
      padding: EdgeInsets.all(16.0),
      child: TextFormField(
        controller: ctrl,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password is required';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
        keyboardType: TextInputType.visiblePassword,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          // prefixIconColor: Colors.red,
          // filled: true,
          // fillColor: const Color.fromARGB(255, 24, 24, 24),
          label: Text("Password"),
          // hint: Text("Password", style: TextStyle(color: Colors.grey)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color.fromARGB(200, 90, 90, 90),
              width: 1.5,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueAccent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          prefixIcon: Icon(Icons.lock),
        ),
        style: TextStyle(color: Colors.black),
        obscureText: true,
        obscuringCharacter: "*",
      ),
    );
  }
}

class EmailAuth extends StatelessWidget {
  const EmailAuth({super.key, required this.ctrl});

  final dynamic ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 322,
      padding: EdgeInsets.all(16.0),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email is required';
          }
          if (!value.contains('@')) {
            return 'Enter a valid email';
          }
          return null;
        },
        controller: ctrl,
        keyboardType: TextInputType.emailAddress,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          // prefixIconColor: Colors.red,
          // filled: true,
          // fillColor: const Color.fromARGB(255, 24, 24, 24),
          label: Text("Email"),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color.fromARGB(200, 90, 90, 90),
              width: 1.5,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueAccent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          prefixIcon: Icon(Icons.email_rounded),
        ),
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

class TextSpace extends StatelessWidget {
  const TextSpace({
    super.key,
    required this.ctrl,
    required this.placeholder,
    required this.icon,
  });

  final dynamic ctrl;
  final dynamic placeholder;
  final dynamic icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 322,
      padding: EdgeInsets.all(16.0),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.text,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          prefixIconColor: Colors.red,
          filled: true,
          fillColor: const Color.fromARGB(255, 24, 24, 24),
          hint: Text("$placeholder", style: TextStyle(color: Colors.grey)),
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
          prefixIcon: Icon(icon),
        ),
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
