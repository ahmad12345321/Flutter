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

  var uname= TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Textfield"),
      ),
    body: Center(
      child: Container(
        child: Center(
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: TextField(
                    obscureText: true,
                    obscuringCharacter: "*",
                    controller: uname,
                    keyboardType: TextInputType.text,
                    // keyboardType: TextInputType.emailAddress,
                    // keyboardType: TextInputType.number,
                    // enabled:false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.icecream),
                      suffixIcon: IconButton(
                        icon:Icon(Icons.remove_red_eye),
                        onPressed: (){
                          print("hello");
                        },
                      ),
                      hintText: "Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.yellow,
                          width: 2
                        )
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(onPressed: (){
                String username=uname.text.toString();
                print("Name,$uname");
              }, child: Text("Sign In"))
            ],
          ),
        ),
      ),
    ),
    );
  }
}
