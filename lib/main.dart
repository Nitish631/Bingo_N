import 'package:bingo_n/database/userInfo.dart';
import 'package:bingo_n/screen/animation.dart';
import 'package:flutter/material.dart';
void main(List<String> args) async{
  UserDatabase userDatabase=UserDatabase.instance;
  userDatabase.database;
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:EntryPage()
    );
  }
}
