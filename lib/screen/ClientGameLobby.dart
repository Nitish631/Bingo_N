import 'package:bingo_n/Dummy/GamingPage.dart';
import 'package:bingo_n/GameData/GameData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientGameLobby extends StatefulWidget {
  const ClientGameLobby({super.key});

  @override
  State<ClientGameLobby> createState() => _ClientGameLobbyState();
}

class _ClientGameLobbyState extends State<ClientGameLobby> {
  GameData gameData = GameData.instance;
  @override
  Widget build(BuildContext context) {
    List playersIdlist = List.from(gameData.playersWithId.keys);
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
                Expanded(flex:3,child: Container()),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: playersIdlist.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      childAspectRatio: 1.5,
                    ),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      String? name =
                          gameData.playersWithId[playersIdlist.elementAt(index)];
                      return Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(33, 251, 0, 1),
                              Color.fromRGBO(51, 159, 0, 1),
                            ],
                            begin: AlignmentGeometry.directional(0, 0),
                            end: AlignmentGeometry.directional(1, 1),
                          ),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Center(
                          child: Text(
                            name!,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(112, 0, 0, 1),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    child: Center(
                      child: Container(
                        height: 80,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(223, 72, 2, 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            "Ready",
                            style: GoogleFonts.poppins(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 0, 255, 255),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
