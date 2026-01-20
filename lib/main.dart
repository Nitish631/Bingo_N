import 'package:bingo_n/GameData/GameData.dart';
import 'package:bingo_n/database/userInfo.dart';
import 'package:bingo_n/screen/GamingPage.dart';
import 'package:bingo_n/screen/RolePage.dart';
// import 'package:bingo_n/screen/animation.dart';
import 'package:flutter/material.dart';
void main(List<String> args) async{
  assignName();
  runApp(const Game());
}
Future<void> assignName()async{
    UserDatabase userDatabase=UserDatabase.instance;
  userDatabase.database;
  GameData gameData=GameData.instance;
  gameData.setName(await userDatabase.getUserName());
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
      home:Gamingpage()
    );
  }
}
