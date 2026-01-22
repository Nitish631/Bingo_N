import 'package:bingo_n/GameData/GameData.dart';
import 'package:bingo_n/screen/ClientGameLobby.dart';
import 'package:bingo_n/screen/HostGameLobby.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class Rolepage extends StatelessWidget {
  Rolepage({super.key});
  final gameData=GameData.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20,),
              Text(
                "BINGO",
                style: GoogleFonts.openSans(
                  fontSize: 65,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(255, 102, 0, 1),
                ),
              ),
              SizedBox(height: 300,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      gameData.isServer=true;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder) => HostGameLobby()),
                      );
                    },
                    
                    child: Container(
                      width: 100,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color.fromRGBO(21, 0, 255, 1)
                      ),
                      child: Center(
                        child: Text(
                          "HOST",
                          style: GoogleFonts.poppins(
                            color: Color.fromRGBO(255, 187, 0, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      gameData.isServer=false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder) => HostGameLobby()),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color.fromRGBO(21, 0, 255, 1)
                      ),
                      child: Center(
                        child: Text(
                          "USER",
                          style: GoogleFonts.poppins(
                            color: Color.fromRGBO(255, 187, 0, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 18
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
    );
  }
}
