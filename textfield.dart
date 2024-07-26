import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontFamily:'fontone',
              fontWeight: FontWeight.bold,

          )
        )
      ),
      home: textfield(),
    );
  }
}
class textfield extends StatefulWidget {
  const textfield({super.key});

  @override
  State<textfield> createState() => _textfieldState();
}


class _textfieldState extends State<textfield> {
  var uname=TextEditingController();
  var uemail=TextEditingController();
  var upass=TextEditingController();
  var uconfirm=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.cyan,
        backgroundColor: Colors.blue,
        title: Text("Textfield"),
      ),
    body:Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          shadowColor: Colors.red,
          elevation: 20,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
                color: Colors.blue
            ),
            width: 400,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: uname,
                      keyboardType:TextInputType.text,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Name',
                        // suffixIcon: IconButton(
                        //   icon: Icon(Icons.remove_red_eye,color: Colors.blueAccent,),
                        //   onPressed: (){
                        //     print('Raza');
                        //   },
                        // ),
                        prefixIcon: Icon(Icons.drive_file_rename_outline,color: Colors.blueAccent,),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.pink
                          )
                        )
                      ),
                      ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: uemail,
                      decoration:InputDecoration(
                        prefixIcon: Icon(Icons.email,color: Colors.blueAccent,),
                        hintText: "Email",
                        // suffixIcon: IconButton(
                        //   icon: Icon(Icons.remove_red_eye,color: Colors.blueAccent,),
                        //   onPressed: (){
                        //     print("Email");
                        //   },
                        // ),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius:BorderRadius.circular(10)
                        )
                      ) ,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      obscureText: true,
                      obscuringCharacter: '*',
                      controller: upass,
                      keyboardType: TextInputType.text,
                      decoration:InputDecoration(
                          prefixIcon: Icon(Icons.password,color: Colors.blueAccent,),
                          hintText: "Password",
                          suffixIcon: IconButton(
                            icon:Icon(Icons.remove_red_eye,color: Colors.blueAccent,),
                            onPressed: (){
                              print("Password");
                            },
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius:BorderRadius.circular(10)
                          )
                      ) ,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      obscuringCharacter: "*",
                      obscureText: true,
                      controller: uconfirm,
                      keyboardType: TextInputType.text,
                      decoration:InputDecoration(
                          prefixIcon: Icon(Icons.password,color: Colors.blueAccent,),
                          hintText: "Confirm Password",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.remove_red_eye,color: Colors.blueAccent,),
                            onPressed: (){
                              print("Confirm Password");
                            },
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius:BorderRadius.circular(10)
                          ),

                      ) ,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(onPressed: (){
                      String username=uname.text.toString();
                      String useremail=uemail.text.toString();
                      String userpass=upass.text.toString();
                      String userconfirm=uconfirm.text.toString();
                    print("Name :$username Email :$useremail Password :$userpass Confirm Password :$userconfirm");
                    }, child: Text("Sign In")),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
