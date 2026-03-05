import 'dart:io';
import 'dart:math';

import 'package:bingo_n/GameData/GameData.dart';
import 'package:bingo_n/screen/RolePage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class wonPage extends StatefulWidget {
  const wonPage({super.key});

  @override
  State<wonPage> createState() => _wonPageState();
}

class _wonPageState extends State<wonPage> with SingleTickerProviderStateMixin {
  GameData gameData = GameData.instance;
  late AnimationController animationController;
  late Animation<double> animation;
  late Animation<double> colorValue;
  late Animation<double> waveAnimation;
  @override
  void initState() {
    // TODO: implement initState
    gameData.gameStarted = false;
    gameData.goToWinPage=false;
    gameData.sendDataForCommunication();
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.stop();
        animationController.duration = Duration(milliseconds: 800);
        animationController.repeat(min: 0.7, max: 1.0);
      }
    });
    animation = Tween<double>(begin: 0, end: 300).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0, 0.2, curve: Curves.easeInOut),
      ),
    );
    colorValue = Tween<double>(begin: 0, end: 800).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.28, 0.68, curve: Curves.easeInOut),
      ),
    );
    waveAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.7, 1, curve: Curves.easeInOut),
      ),
    );
    animationController.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
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
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              child: Column(
                children: [
                  Center(
                    child: Transform.translate(
                      offset: Offset(0, 340 - animation.value),
                      child: Container(
                        height: animation.value / 2,
                        width: double.infinity,
                        child: Center(
                          child: buildWaveText(
                            "${gameData.playersWithId[gameData.wonId].toString().toUpperCase()} WON",
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 50,
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildWaveText(String text) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(text.length, (index) {
            // wave calculation
            double waveOffset = sin(waveAnimation.value + (index * 0.6)) * 10;

            return Transform.translate(
              offset: Offset(0, waveOffset),
              child: Text(
                text[index],
                style: GoogleFonts.poppins(
                  fontSize: animation.value / 8,
                  fontWeight: FontWeight.w900,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [
                        Color.fromRGBO(255, 0, 0, 1),
                        Color.fromRGBO(255, 150, 0, 1),
                        Color.fromRGBO(255, 0, 0, 1),
                        Color.fromRGBO(255, 150, 0, 1),
                      ],
                    ).createShader(Rect.fromLTRB(0, 0, colorValue.value, 100)),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
