import 'package:bingo_n/GameData/GameData.dart';
import 'package:bingo_n/screen/HostGameLobby.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Rolepage extends StatelessWidget {
  Rolepage({super.key});
  final gameData = GameData.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: Container(
            height: 500,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "BINGO",
                  style: GoogleFonts.openSans(
                    fontSize: 65,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          Color.fromRGBO(255, 0, 0, 1),
                          Color.fromRGBO(255, 102, 0, 1),
                          Color.fromRGBO(255, 200, 0, 1),
                        ],
                      ).createShader(Rect.fromLTWH(0, 0, 300, 70)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        gameData.isServer = true;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => HostGameLobby(),
                          ),
                        );
                      },

                      child: Container(
                        width: 120,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color.fromRGBO(223, 72, 2, 1),
                        ),
                        child: Center(
                          child: Text(
                            "HOST",
                            style: GoogleFonts.poppins(
                              color: const Color.fromARGB(255, 0, 255, 255),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        gameData.isServer = false;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => HostGameLobby(),
                          ),
                        );
                      },
                      child: Container(
                        width: 120,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color.fromRGBO(223, 72, 2, 1),
                        ),
                        child: Center(
                          child: Text(
                            "USER",
                            style: GoogleFonts.poppins(
                              color: const Color.fromARGB(255, 0, 255, 255),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
