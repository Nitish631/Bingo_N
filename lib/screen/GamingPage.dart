// import 'package:bingo_n/GameState/state.dart';
import 'package:bingo_n/screen/wonPage.dart';
import 'package:flutter/material.dart';
// import 'package:bingo_n/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';

class Gamingpage extends StatefulWidget {
  const Gamingpage({super.key});

  @override
  State<Gamingpage> createState() => _GamingpageState();
}

List<String> bingo = ['B', 'I', 'N', 'G', 'O'];
int bingoIndex = 0;
final List<List<int>> winningList = [
  [0, 1, 2, 3, 4],
  [5, 6, 7, 8, 9],
  [10, 11, 12, 13, 14],
  [15, 16, 17, 18, 19],
  [20, 21, 22, 23, 24],
  [0, 5, 10, 15, 20],
  [1, 6, 11, 16, 21],
  [2, 7, 12, 17, 22],
  [3, 8, 13, 18, 23],
  [4, 9, 14, 19, 24],
  [0, 6, 12, 18, 24],
  [4, 8, 12, 16, 20],
];
List<bool> PatternMatched = List.generate(12, (e) => false);
List<String> PatternMatchedStringData = List.generate(12, (e) => '');
bool isWon() {
  patternMatchedUpdate();
  int countOfMatchedPattern = 0;
  for (bool i in PatternMatched) {
    if (i) {
      countOfMatchedPattern++;
    }
  }
  if (countOfMatchedPattern == 5) {
    return true;
  }
  return false;
}

void patternMatchedUpdate() {
  for (List<int> wonpattern in winningList) {
    int clickedBoxInPattern = 0;
    for (int i in wonpattern) {
      if (isClicked[i] == true) clickedBoxInPattern++;
    }
    if (clickedBoxInPattern == 5) {
      PatternMatched[winningList.indexOf(wonpattern)] = true;
      if (PatternMatchedStringData[winningList.indexOf(wonpattern)] == '') {
        PatternMatchedStringData[winningList.indexOf(wonpattern)] =
            bingo[bingoIndex];
        bingoIndex++;
      }
    }
  }
}

List<bool> isClicked = List.generate(25, (e) => false);

class _GamingpageState extends State<Gamingpage> {
  List<int> pattterrn = List.generate(25, (index) => index);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(255, 0, 160, 1),
            Color.fromRGBO(170, 0, 255, 1),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            // "$myName",
            "Nitish",
            style: GoogleFonts.roboto(
              fontSize: 30,
              color: const Color.fromARGB(255, 255, 64, 0),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            // "$hostName",
            "Host name:",
            style: GoogleFonts.roboto(
              fontSize: 30,
              color: const Color.fromARGB(255, 255, 64, 0),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 19),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 330,
                  width: 50,
                  child: Column(
                    children: List.generate(6, (index) {
                      int matchingIndex;
                      if (index == 0) {
                        matchingIndex = 10;
                      } else {
                        matchingIndex = index - 1;
                      }
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4.8),
                        height: 45,
                        width: 45,
                        child: Center(
                          child: Text(
                            "${PatternMatchedStringData[matchingIndex]}",
                            style: GoogleFonts.roboto(
                              fontSize: 28,
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      height: 50,
                      width: 280,
                      alignment: AlignmentGeometry.topLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(5, (index) {
                          int matchingIndex = index + 5;
                          return Container(
                            margin: EdgeInsets.all(2),
                            height: MediaQuery.of(context).size.width * 0.102,
                            width: MediaQuery.of(context).size.width * 0.102,
                            child: Center(
                              child: Text(
                                '${PatternMatchedStringData[matchingIndex]}',
                                style: GoogleFonts.roboto(
                                  fontSize: 28,
                                  color: Colors.cyanAccent,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Container(
                      height: 280,
                      width: 280,
                      child: Center(
                        child: Column(
                          children: [
                            Row(
                              children: List.generate(5, (index) {
                                return Container(
                                  padding: EdgeInsets.zero,
                                  height: 52,
                                  width: 52,
                                  margin: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isClicked[index]
                                        ? Colors.cyanAccent.withOpacity(0.8)
                                        : Colors.cyanAccent,
                                    border: Border.all(
                                      width: 2.5,
                                      color: Color.fromRGBO(144, 2, 2, 1),
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isClicked[index] = true;
                                      });
                                      if (isWon()) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => wonPage(),
                                          ),
                                        );
                                      }
                                      setState(() {});
                                    },
                                    child: Center(
                                      child: Text(
                                        "${pattterrn[index].toString()}",
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
                                          color: isClicked[index]
                                              ? Colors.brown
                                              : const Color.fromARGB(255, 255, 64, 0),
                                          fontSize: 19,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return Container(
                                  padding: EdgeInsets.zero,
                                  height: 52,
                                  width: 52,
                                  margin: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isClicked[index + 5]
                                        ? Colors.cyanAccent.withOpacity(0.8)
                                        : Colors.cyanAccent,
                                    border: Border.all(
                                      width: 2.5,
                                      color: Color.fromRGBO(144, 2, 2, 1),
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isClicked[index + 5] = true;
                                      });
                                      if (isWon()) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => wonPage(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        "${pattterrn[index + 5].toString()}",
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
                                          color: isClicked[index + 5]
                                              ? Colors.brown
                                              : const Color.fromARGB(255, 255, 64, 0),
                                          fontSize: 19,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return Container(
                                  padding: EdgeInsets.zero,
                                  height: 52,
                                  width: 52,
                                  margin: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isClicked[index + 10]
                                        ? Colors.cyanAccent.withOpacity(0.8)
                                        : Colors.cyanAccent,
                                    border: Border.all(
                                      width: 2.5,
                                      color: Color.fromRGBO(144, 2, 2, 1),
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isClicked[index + 10] = true;
                                      });
                                      if (isWon()) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => wonPage(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        "${pattterrn[index + 10].toString()}",
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
                                          color: isClicked[index + 10]
                                              ? Colors.brown
                                              : const Color.fromARGB(255, 255, 64, 0),
                                          fontSize: 19,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return Container(
                                  padding: EdgeInsets.zero,
                                  height: 52,
                                  width: 52,
                                  margin: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color:  isClicked[index + 15]
                                        ? Colors.cyanAccent.withOpacity(0.8)
                                        : Colors.cyanAccent,
                                    border: Border.all(
                                      width: 2.5,
                                      color: Color.fromRGBO(144, 2, 2, 1),
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isClicked[index + 15] = true;
                                      });
                                      if (isWon()) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => wonPage(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        "${pattterrn[index + 15].toString()}",
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
                                          color: isClicked[index + 15]
                                              ? Colors.brown
                                              : const Color.fromARGB(255, 255, 64, 0),
                                          fontSize: 19,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return Container(
                                  padding: EdgeInsets.zero,
                                  height: 52,
                                  width: 52,
                                  margin: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isClicked[index + 20]
                                        ? Colors.cyanAccent.withOpacity(0.8)
                                        : Colors.cyanAccent,
                                    border: Border.all(
                                      width: 2.5,
                                      color: Color.fromRGBO(144, 2, 2, 1),
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isClicked[index + 20] = true;
                                      });
                                      if (isWon()) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => wonPage(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        "${pattterrn[index + 20].toString()}",
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
                                          color: isClicked[index + 20]
                                              ? Colors.brown
                                              : const Color.fromARGB(255, 255, 64, 0),
                                          fontSize: 19,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 330,
                  width: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 2),
                        height: 45,
                        width: 45,
                        child: Center(
                          child: Text(
                            "${PatternMatchedStringData[11]}",
                            style: GoogleFonts.roboto(
                              fontSize: 28,
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
