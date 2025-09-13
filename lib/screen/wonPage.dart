import 'package:flutter/material.dart';
class wonPage extends StatefulWidget {
  const wonPage({super.key});

  @override
  State<wonPage> createState() => _wonPageState();
}

class _wonPageState extends State<wonPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color.fromRGBO(255, 0, 160, 1),
              Color.fromRGBO(170, 0, 255, 1),
            ]
          )
        ),
      ),
    );
  }
}