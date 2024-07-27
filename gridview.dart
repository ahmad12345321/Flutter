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
  var colorss=[
    Colors.red,
    Colors.pink,
    Colors.yellow,
    Colors.pinkAccent,
    Colors.amber,
    Colors.teal,
    Colors.black
  ];
  var time=DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My App"),
      ),
      body: GridView.count(crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorss[0],
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.ad_units,size:20, color: Colors.white,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(text: TextSpan(
                        children:[
                          TextSpan(
                            text: "My Name is Muhammad Ahmad Raza Khan.",style: TextStyle(
                            color: Colors.white
                          )
                          ),
                          TextSpan(
                            text: "I am studying software engineering in Numl Uiversty",style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16
                          )
                          )
                        ]
                      )),
                    )
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorss[2],
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.ad_units,size:20, color: Colors.white,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(text: TextSpan(
                          children:[
                            TextSpan(
                                text: "My Name is Muhammad Ahmad Raza Khan.",style: TextStyle(
                                color: Colors.white
                            )
                            ),
                            TextSpan(
                                text: "I am studying software engineering in Numl Uiversty",style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16
                            )
                            )
                          ]
                      )),
                    )
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorss[4],
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.ad_units,size:20, color: Colors.white,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(text: TextSpan(
                          children:[
                            TextSpan(
                                text: "My Name is Muhammad Ahmad Raza Khan.",style: TextStyle(
                                color: Colors.white
                            )
                            ),
                            TextSpan(
                                text: "I am studying software engineering in Numl Uiversty",style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16
                            )
                            )
                          ]
                      )),
                    )
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorss[6],
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.ad_units,size:20, color: Colors.white,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(text: TextSpan(
                          children:[
                            TextSpan(
                                text: "My Name is Muhammad Ahmad Raza Khan.",style: TextStyle(
                                color: Colors.white
                            )
                            ),
                            TextSpan(
                                text: "I am studying software engineering in Numl Uiversty",style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16
                            )
                            )
                          ]
                      )),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
