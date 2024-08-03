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
      home:dashbaord(),
    );
  }
}
class dashbaord extends StatefulWidget {
  const dashbaord({super.key});

  @override
  State<dashbaord> createState() => _dashbaordState();
}

class _dashbaordState extends State<dashbaord> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My App"),
        backgroundColor: Colors.blue,
      ),
      body:Container(
        color: Colors.red,
        width: double.infinity,
        height:double.infinity,
        child: Stack(
          children: [
            Positioned(
              // bottom: 100,
              // left: 20,
              // top: 40,
              // left: 40,
              right: 20,
              top: 40,
              // bottom: 100,
              // right: 10,
              child: Container(
                width: 100,
                height:100,
                color: Colors.blue,
              ),
            )
          ],
        ),
      ),
    );
  }
}
