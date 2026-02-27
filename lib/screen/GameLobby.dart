import 'package:bingo_n/Communication/Client.dart';
import 'package:bingo_n/Communication/Server.dart';
import 'package:bingo_n/Dummy/GamingPage.dart';
import 'package:bingo_n/GameData/GameData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameLobby extends StatefulWidget {
  const GameLobby({super.key});

  @override
  State<GameLobby> createState() => _GameLobbyState();
}

class _GameLobbyState extends State<GameLobby> {
  GameData gameData = GameData.instance;
  bool ready=false;
  late bool isServer;
  @override
  void initState() {
    // TODO: implement initState
    if (gameData.isServer) {
      Server server = Server.instance;
      server.start();
      isServer=true;
    } else {
      Client client = Client.instance;
      print(gameData.playersWithId);
      // client.start();
      isServer=false;
      print("CLIENTS");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(10),
        child: AnimatedBuilder(
          animation: GameData.instance,
          builder: (context, _) {
            List<MapEntry<int, String>> playerEntries = gameData
                .playersWithId
                .entries
                .toList();
            if (gameData.gameStarted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: ((context) => GamingPage())),
              );
            }
            return Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    // color: Colors.teal,
                    height: double.infinity,
                    width: double.infinity,
                    child: Column(
                      children: [
                        const Spacer(),
                        GridView.builder(
                          shrinkWrap: true,
                          itemCount: playerEntries.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 15,
                                childAspectRatio: 1.5,
                              ),
                          itemBuilder: (context, index) {
                            MapEntry<int, String> entry = playerEntries[index];
                            int id = entry.key;
                            String name = entry.value;
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: gameData.isReadyPlayer(id)
                                    ? const Color.fromARGB(255, 59, 221, 0)
                                    : const Color.fromARGB(255, 143, 24, 0),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Center(
                                    child: Text(
                                      "$name",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(
                                          255,
                                          255,
                                          213,
                                          0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  isServer?
                                  Positioned(
                                    top: 3,
                                    right: 3,
                                    child: InkWell(
                                      onTap: () {
                                        gameData.removeClient(id);
                                      },
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.white,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ):SizedBox(),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Center(
                      child: Container(
                        height: 70,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color.fromRGBO(223, 72, 2, 1),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (isServer) {
                              int count = gameData
                                  .returnNOnReadyPlayersCountWhileStarting();
                              if (count != 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color.fromARGB(
                                      133,
                                      120,
                                      120,
                                      120,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(15),
                                    ),
                                    content: Text(
                                      "Not all players are ready.",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    width: 150,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                                return;
                              }
                              gameData.sendDataForCommunication();
                            }else{
                              ready=gameData.readyPlayers.contains(gameData.myId);
                              gameData.notifyReadyToServer(!ready);
                              ready=!ready;
                            }
                          },
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                isServer?
                                "Start":ready? "Not Ready":"Ready",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 0, 255, 255),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
