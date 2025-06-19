import 'package:flutter/material.dart';

class LoginMaterialPage extends StatefulWidget{
  const LoginMaterialPage({super.key});

  @override
  State<LoginMaterialPage> createState()=>_LoginMaterialPageState();
}

class _LoginMaterialPageState extends State<LoginMaterialPage>{
TextEditingController userName = TextEditingController();
  TextEditingController passWord = TextEditingController();

String? username;
 String? password;
  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(200, 90, 90, 90),
                        width: 1.5,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    );
    return Scaffold(
        backgroundColor: const Color.fromARGB(246, 0, 0, 0),
        body: Center(
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
                padding: EdgeInsets.all(20),
                child: TextField(
                  style: TextStyle(
                    color: const Color.fromARGB(255, 119, 119, 119)
                  ),
                  controller: userName,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.account_circle_outlined),
                    prefixIconColor: const Color.fromARGB(255, 230, 13, 13),
                    filled: true,
                    fillColor: const Color.fromARGB(149, 32, 32, 32),
                    hintText: "User Name :",
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(224, 151, 151, 151),
                    ),
                    enabledBorder: border,
                    focusedBorder: border,
                    // label: Text("User Name")
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: TextField(
                  style: TextStyle(
                    color: const Color.fromARGB(255, 119, 119, 119)
                  ),
                  controller: passWord,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password, ),
                    prefixIconColor: const Color.fromARGB(255, 255, 34, 34),
                    filled: true,
                    fillColor: const Color.fromARGB(149, 32, 32, 32),
                    hintText: "Password :",
                    // obscure: true,
                    // obscure: true,
                    // label: Text("Password"),
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(224, 151, 151, 151),
                    ),
                    enabledBorder: border,
                    focusedBorder: border,
                  ),
                  keyboardType: TextInputType.numberWithOptions(
                    signed: false,
                  ),
                ),
                
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(onPressed: (){
                  username=userName.text;
                  password= passWord.text;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(234, 22, 22, 22),
                  elevation: 20,
                  foregroundColor: const Color.fromARGB(197, 100, 100, 100),
                  
                ), child: Text("Login")),
              )
            ],
          ),
        ),
      );
  }
}