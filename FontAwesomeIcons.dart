import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My App"),
      ),
     body: Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: Icon(Icons.access_alarms_rounded, size: 100,color: Colors.red,),
           ),
           FaIcon(FontAwesomeIcons.amazon, size: 100, color: Colors.red,),
           FaIcon(FontAwesomeIcons.facebook,color: Colors.blue,size: 100,),
           FaIcon(FontAwesomeIcons.whatsapp,size: 100,color: Colors.green,),
           FaIcon(FontAwesomeIcons.instagram)
         ],
       ),
     ),
    );
  }

}
