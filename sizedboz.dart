import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:Myappscreen(),
    );
  }
}

class Myappscreen extends StatefulWidget {
  const Myappscreen({super.key});

  @override
  State<Myappscreen> createState() => _MyappscreenState();
}

class _MyappscreenState extends State<Myappscreen> {
  var time=DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My App"),
      ),
     // body: RichText(
     //
     //   text: TextSpan(
     //     style: TextStyle(
     //       color: Colors.grey,
     //       fontSize: 40
     //     ),
     //     children: [
     //       TextSpan(text: "Muhammad",style: TextStyle(color: Colors.red)),
     //       TextSpan(text: " Ahmad ",style: TextStyle(color:Colors.cyan)),
     //       TextSpan(text: " Raza")
     //     ],
     //   ),
     // ),
      body:SizedBox(
        width: 200,
        height: 50,
        child: ElevatedButton(
          onPressed: (){
            return null;
          },
          child: Text("clcik"),
        ),
      ),
    );
  }
}
