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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Textfield"),
      ),
      body: InkWell(
        // onTap:(){
        //   print("Muhammad Ahmad Raza");
        // },
          onDoubleTap: (){
            print("Muhammad Ahmad Raza");
          },
        child: Center(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text("My Name is Muhammad Ahmad Raza" , style:Theme.of(context).textTheme.headlineLarge,)),
            ),
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
                border: Border.all(
                  width: 2,
                  color: Colors.black,
                ),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 20,
                      spreadRadius: 2
                  )
                ]
            ),
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
