import 'package:bingo_n/Communication/Client.dart';
import 'package:bingo_n/Communication/Server.dart';
import 'package:bingo_n/Dummy/GamingPage.dart';
import 'package:bingo_n/GameData/GameData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HostGameLobby extends StatefulWidget {
  const HostGameLobby({super.key});

  @override
  State<HostGameLobby> createState() => _HostGameLobbyState();
}

class _HostGameLobbyState extends State<HostGameLobby> {
  GameData gameData = GameData.instance;
  @override
  void initState() {
    // TODO: implement initState
    if (gameData.isServer) {
      Server server = Server.instance;
      server.start();
    } else {
      Client client = Client.instance;
      client.start();
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
            print(playerEntries);
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
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                                childAspectRatio: 2.2,
                              ),
                          itemBuilder: (context, index) {
                            MapEntry<int, String> entry = playerEntries[index];
                            int id = entry.key;
                            String name = entry.value;
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color.fromARGB(255, 90, 23, 10),
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
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
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
                                  ),
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
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color.fromRGBO(122, 95, 0, 1),
                        ),
                        child: InkWell(
                          onTap: () {
                            int count=gameData.returnNOnReadyPlayersCountWhileStarting();
                            gameData.sendDataForCommunication();
                          },
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "Start",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
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
