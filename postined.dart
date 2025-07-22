import 'package:flutter/material.dart';
class postined extends StatefulWidget {
  const postined({super.key});

  @override
  State<postined> createState() => _postinedState();
}

class _postinedState extends State<postined> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 400,
                width: 600,
                child: Stack(

                  children: [
                    Container(
                      color: Colors.red,
                      height: double.infinity,
                      width: double.infinity,
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        color: Colors.grey.shade500,
                        height: 100,
                        width: 100,
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        color: Colors.grey.shade500,
                        height: 100,
                        width: 100,
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        color: Colors.grey.shade500,
                        height: 100,
                        width: 100,
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Container(
                        color: Colors.grey.shade500,
                        height: 100,
                        width: 100,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
