import 'package:bingo_n/DTOs/ClientSendDto.dart';
import 'package:bingo_n/Dummy/Client.dart';
import 'package:bingo_n/Dummy/GameData.dart';
import 'package:bingo_n/Dummy/Server.dart';
import 'package:bingo_n/Dummy/navData.dart';
import 'package:bingo_n/screen/wonPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GamingPage extends StatefulWidget {
  final communication;

  const GamingPage({super.key, required this.communication});

  @override
  State<GamingPage> createState() => _GamingPageState();
}

class _GamingPageState extends State<GamingPage> {
  var communication;
  Gamedata gameData = Gamedata.instance;
  @override
  void initState() {
    communication = widget.communication;
    communication.modifyContext(context);
    super.initState();
  }

  void removeClient(int id) {
    if (communication is Server) {
      (communication as Server).removeClient(id);
    }
  }

  
 Color unClickedContainerColor = const Color.fromARGB(255, 0, 213, 255);
  Color ClickedContainerColor = const Color.fromARGB(170, 0, 213, 255);
 @override
  Widget build(BuildContext context) {
    List playersIdlist = gameData.playersWithId.entries.toList();
    double width = MediaQuery.of(context).size.width * 0.9;
    double height = width * 6 / 7;
    return Scaffold(
      body: AnimatedBuilder(
        animation: Gamedata.instance,
        builder: (context, child) {
          if (gameData.currentPage==Navdata.rolePage) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
            Navigator.pop(context);
              
            });
          }
          if (gameData.currentPage==Navdata.wonPage) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => wonPage()),
              );
            });
          }
          return Container(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 9,
                  child: Container(
                    child: Center(
                      child: Container(
                        width: width,
                        height: height,
                        child: Row(
                          children: [
                            Container(
                              height: height,
                              width: width / 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(6, (i) {
                                  int patternIndex;
                                  if (i == 0) {
                                    patternIndex = 10;
                                  } else {
                                    patternIndex = i - 1;
                                  }
                                  return Container(
                                    height: height / 6,
                                    width: height / 6,
                                    child: Center(
                                      child: Text(
                                        gameData.getCharIfPatternMatched(
                                          patternIndex,
                                        ),
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepOrange,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            Container(
                              height: height,
                              width: height,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: height / 6,
                                    child: Row(
                                      children: List.generate(6, (i) {
                                        int patternIndex;
                                        if (i == 5) {
                                          patternIndex = 11;
                                        } else {
                                          patternIndex = i + 5;
                                        }
                                        return Container(
                                          height: height / 6,
                                          width: height / 6,
                                          child: Center(
                                            child: Text(
                                              gameData.getCharIfPatternMatched(
                                                patternIndex,
                                              ),
                                              style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepOrange,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: double.infinity,
                                      width: double.infinity,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: Container(
                                              width: width * 5 / 7,
                                              height: width * 5 / 7,
                                              child: Center(
                                                child: GridView.builder(
                                                  padding: EdgeInsets.zero,
                                                  itemCount: 25,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 5,
                                                        crossAxisSpacing: 1,
                                                        mainAxisSpacing: 1,
                                                        childAspectRatio: 1,
                                                      ),
                                                  itemBuilder: (context, index) {
                                                    int element;
                                                    try {
                                                      element = int.parse(
                                                        gameData
                                                            .getElementOfIndexOfMyPattern(
                                                              index,
                                                            ),
                                                      );
                                                    } catch (e) {
                                                      element = -1;
                                                    }
                                                    bool clicked = gameData
                                                        .isClicked(element);
                                                    return InkWell(
                                                      onTap: () {
                                                        if (!gameData
                                                            .isMyTurn())
                                                          return;
                                                        communication.updateGameClickedPattern(element);
                                                      },
                                                      child: Container(
                                                        color: clicked
                                                            ? ClickedContainerColor
                                                            : unClickedContainerColor,
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          gameData
                                                              .getElementOfIndexOfMyPattern(
                                                                index,
                                                              ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Column(
                      children: [
                        Expanded(child: Container()),
                        GridView.builder(
                          shrinkWrap: true,
                          itemCount: playersIdlist.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                                childAspectRatio: 1.5,
                              ),
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            MapEntry<int, String> entry = playersIdlist[index];
                            int id = entry.key;
                            String name = entry.value;
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
                                  name,
                                  style: GoogleFonts.poppins(
                                    fontSize: gameData.isTurnOf(id) ? 25 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: gameData.isTurnOf(id)
                                        ? Color.fromRGBO(255, 0, 234, 1)
                                        : Color.fromRGBO(112, 0, 0, 1),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
