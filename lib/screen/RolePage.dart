import 'package:bingo_n/Communication/Client.dart';
import 'package:bingo_n/GameData/GameData.dart';
import 'package:bingo_n/screen/GameLobby.dart';
import 'package:bingo_n/Communication/Server.dart';
import 'package:bingo_n/DTOs/navData.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Rolepage extends StatelessWidget {
  Rolepage({super.key});
  Gamedata gameData = Gamedata.instance;
  void navigateLobbyIfconnected(BuildContext context,var communication) async {
    if (await isConnectedToWifi()) {
      gameData.currentPage = Navdata.lobby;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => GameLobby(communication: communication,gameData: gameData,)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(15),
        ),
        width: 250,
        backgroundColor: const Color.fromARGB(136, 135, 135, 135),
        content: Row(
          children: [
            Icon(Icons.wifi_off),
            SizedBox(width: 10),
            Text(
              "Connect to a network",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> isConnectedToWifi() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return true;
    // return connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi);
  }
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
                      ).createShader(Rect.fromLTWH(0, 0, 250, 70)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        Server instance=Server.instance;
                        instance.start(context);
                        navigateLobbyIfconnected(context, instance);
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
                        Client instance=Client.instance;
                        instance.start(context);
                        navigateLobbyIfconnected(context, instance);
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
