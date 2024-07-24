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
      body: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/images/one.jpg'),
        ),
        title: Text("Muhammad Ahmad"),
        subtitle: Text("Muhammad Ahmad Raza"),
        trailing: Icon(Icons.icecream),
      ),
    );
  }
}
