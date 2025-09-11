import 'package:bingo_n/GameState/state.dart';
import 'package:bingo_n/screen/GamingPage.dart';
// import 'package:bingo_n/screen/animation.dart';
import 'package:flutter/material.dart';
late final GameState gmst;
void main(List<String> args) async{
  WidgetsFlutterBinding.ensureInitialized();
  gmst=await GameState.getInstance();
  runApp(const Game());
}
class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}
class _GameState extends State<Game> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Gamingpage(),
    );
  }
}
