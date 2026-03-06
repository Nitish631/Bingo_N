import 'package:bingo_n/screen/animation.dart';
import 'package:flutter/material.dart';
void main(List<String> args) async{
  runApp(const Game());
}
class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}
class _GameState extends State<Game> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Color.fromRGBO(0, 44, 75, 1)),
      home:EntryPage()
    );
  }
}
