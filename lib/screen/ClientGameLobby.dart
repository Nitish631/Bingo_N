import 'dart:ffi';

import 'package:bingo_n/Dummy/GamingPage.dart';
import 'package:bingo_n/GameData/GameData.dart';
import 'package:flutter/material.dart';

class ClientGameLobby extends StatefulWidget {
  const ClientGameLobby({super.key});

  @override
  State<ClientGameLobby> createState() => _ClientGameLobbyState();
}

class _ClientGameLobbyState extends State<ClientGameLobby> {
  GameData gameData = GameData.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: GameData.instance,
        builder: (context, _) {
          if (gameData.gameStarted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: ((context) => GamingPage())),
            );
          }
          return Container(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          childAspectRatio: 1
                        ),
                        itemBuilder: (context, index) {},
                      ),
                    ),
                  ),
                ),
                Expanded(flex: 2,child: Container()),
              ],
            ),
          );
        },
      ),
    );
  }
}
