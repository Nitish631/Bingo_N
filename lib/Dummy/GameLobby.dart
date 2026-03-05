import 'package:bingo_n/Dummy/Client.dart';
import 'package:bingo_n/Dummy/GameData.dart';
import 'package:bingo_n/Dummy/GamingPage.dart';
import 'package:bingo_n/Dummy/Server.dart';
import 'package:bingo_n/Dummy/navData.dart';
import 'package:bingo_n/GameData/ConnectionStatus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameLobby extends StatefulWidget {
  final Gamedata gameData;
  final communication;
  const GameLobby({
    super.key,
    required this.communication,
    required this.gameData,
  });

  @override
  State<GameLobby> createState() => _GameLobbyState();
}

class _GameLobbyState extends State<GameLobby> {
  late Gamedata gameData;
  bool isServer = false;
  @override
  void initState() {
    isServer = widget.communication is Server;
    gameData = widget.gameData;
    gameData.currentPage = Navdata.lobby;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.communication.mofidyContext(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(10),
        child: AnimatedBuilder(
          animation: gameData,
          builder: (context, _) {
            List<MapEntry<int, String>> playerEntries = gameData
                .playersWithId
                .entries
                .toList();
            if (gameData.currentPage == Navdata.gamingPage) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: ((context) =>
                        GamingPage(communication: widget.communication)),
                  ),
                );
              });
            }
            if (gameData.currentPage == Navdata.lobby) {
              gameData.clear();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                Navigator.pop(context);
              });
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
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: gameData.isPlayerReady(id)
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
                                  isServer && id != gameData.serverId
                                      ? Positioned(
                                          top: 3,
                                          right: 3,
                                          child: InkWell(
                                            onTap: () {
                                              (widget.communication as Server)
                                                  .removeClient(id);
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
                                        )
                                      : SizedBox(),
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
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
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
                                  if (!(gameData.connectionStatus.status ==
                                      Status.connected)) {
                                    widget.communication.start(context);
                                    return;
                                  }
                                  if (gameData.playersWithId.isEmpty) {
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
                                          "No players",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        width: 130,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                    return;
                                  }
                                  if (widget.communication is Server) {
                                    int count = gameData.noOfNotReadyPlayers();
                                    if (count != 0) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: const Color.fromARGB(
                                            133,
                                            120,
                                            120,
                                            120,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadiusGeometry.circular(
                                                  15,
                                                ),
                                          ),
                                          content: Text(
                                            "$count ${count == 1 ? "player is not" : "players are not"} ready.",
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

                                    (widget.communication as Server).sendNavigateToGamingPage();
                                  } else {
                                    bool ready = gameData.isReady();
                                    (widget.communication as Client)
                                        .notifyReadyToAll(!ready);
                                  }
                                },
                                child: Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      !(gameData.connectionStatus.status ==
                                              Status.connected)
                                          ? "Reconnect"
                                          : isServer
                                          ? "Start"
                                          : gameData.isReady()
                                          ? "Not Ready"
                                          : "Ready",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(
                                          255,
                                          0,
                                          255,
                                          255,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Center(
                            child: Container(
                              child: Text(
                                "${gameData.connectionStatus.message}",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
