import 'dart:io';
import 'dart:math';

import 'package:bingo_n/Communication/Client.dart';
import 'package:bingo_n/Communication/Server.dart';
import 'package:bingo_n/GameData/GameData.dart';
import 'package:bingo_n/screen/RolePage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class wonPage extends StatefulWidget {
  final communication;
  const wonPage({super.key, required this.communication});

  @override
  State<wonPage> createState() => _wonPageState();
}

class _wonPageState extends State<wonPage> with SingleTickerProviderStateMixin {
  Gamedata gameData = Gamedata.instance;
  late AnimationController animationController;
  late Animation animation;
  @override
  void initState() {
    widget.communication.modifyContext(context);
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    animation = Tween<double>(begin: 85, end: 400).animate(
      CurvedAnimation(parent: animationController, curve: Curves.bounceIn),
    );
    super.initState();
    animationController.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Server.instance.dispose();
    Client.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              const Color.fromRGBO(0, 75, 113, 1),
              const Color.fromARGB(255, 0, 146, 219),
              const Color.fromARGB(255, 0, 255, 229),
            ],
          ),
        ),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Positioned(
                    bottom: animation.value,
                    left: 0,
                    right: 0,
                    child: Container(
                      child: Center(
                        child: Container(
                          height: animation.value / 2,
                          decoration: BoxDecoration(
                            // color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  "${gameData.playersWithId[gameData.wonId]==null?"":gameData.playersWithId[gameData.wonId]!.toUpperCase()}",
                                  style: GoogleFonts.poppins(
                                    fontSize: animation.value / 8,
                                    foreground: Paint()
                                      ..shader =
                                          LinearGradient(
                                            colors: [
                                              Color(0xFFFF0000),
                                              Color(0xFFFF6A00),
                                              Color.fromARGB(255, 226, 255, 7),
                                            ],
                                          ).createShader(
                                            Rect.fromLTWH(0, 0, 400, 100),
                                          ),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  "WINNER",
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: animation.value / 6,
                                    foreground: Paint()
                                      ..shader =
                                          LinearGradient(
                                            colors: [
                                              Color.fromARGB(255, 255, 242, 0),
                                              Color(0xFFFF6A00),
                                            ],
                                          ).createShader(
                                            Rect.fromLTWH(0, 0, 400, 100),
                                          ),
                                    letterSpacing: 5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 50,
                right: 0,
                left: 0,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Rolepage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Container(
                        height: 70,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color.fromARGB(255, 247, 95, 0),
                        ),
                        child: Center(
                          child: Text(
                            "Return",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
