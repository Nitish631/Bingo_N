import 'package:bingo_n/GameData/GameData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GamingPage extends StatefulWidget {
  const GamingPage({super.key});

  @override
  State<GamingPage> createState() => _GamingPageState();
}

class _GamingPageState extends State<GamingPage> {
  GameData gameData = GameData.instance;
  Color unClickedContainerColor=const Color.fromARGB(255,0,213,255,);
  Color ClickedContainerColor=const Color.fromARGB(170, 0, 213, 255);
  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width * 0.9;
    double height = width * 6 / 7;
    return Scaffold(
      body: AnimatedBuilder(
        animation: GameData.instance,
        builder: (context, child) {
          return Container(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
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
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: width * 5 / 7,
                                        height: width * 5 / 7,
                                        child: GridView.builder(
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 5,
                                                crossAxisSpacing: 0.1,
                                                mainAxisSpacing: 0.1,
                                                childAspectRatio: 1,
                                              ),
                                          itemBuilder: (context, index) {
                                            int element;
                                            try{
                                              element=int.parse(gameData.getElementOfIndexOfMyPattern(index));
                                            }catch(e){
                                              element=-1;
                                            }
                                            bool clicked=gameData.isClicked(element);
                                            return InkWell(
                                              onTap: () {
                                                if (gameData.isMyTurn()) {
                                                  gameData
                                                      .updateGameClickedPattern(
                                                        element,
                                                      );
                                                }
                                                gameData.calculateWon();
                                                gameData.sendDataForCommunication();
                                              },
                                              child: Container(
                                                color: clicked?ClickedContainerColor:unClickedContainerColor,
                                                alignment: Alignment.center,
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
                                    ],
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
                Expanded(flex: 1, child: Container(color: Colors.red)),
              ],
            ),
          );
        },
      ),
    );
  }
}
