import 'package:bingo_n/GameData/GameData.dart';
import 'package:bingo_n/screen/ClientGamingPage.dart';
import 'package:flutter/material.dart';

class ClientGameLobby extends StatefulWidget {
  const ClientGameLobby({super.key});

  @override
  State<ClientGameLobby> createState() => _ClientGameLobbyState();
}

class _ClientGameLobbyState extends State<ClientGameLobby> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: GameData.instance,
        builder: (context, _) {
          final gameData = GameData.instance;
          if (gameData.gameStarted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: ((context) => ClientGamingPage())),
            );
          }
          return Container(height: double.infinity, width: double.infinity);
        },
      ),
    );
  }
}
