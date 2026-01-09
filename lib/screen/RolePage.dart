import 'package:bingo_n/GameState/state.dart';
import 'package:bingo_n/Roles/client.dart';
import 'package:bingo_n/Roles/host.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Rolepage extends StatelessWidget {
  const Rolepage({super.key});
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
                  ElevatedButton(
                    onPressed: () {
                      isHost=true;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder) => HostPage()),
                      );
                    },
                    child: const Text(
                      "HOST",
                      style: TextStyle(
                        color: Color.fromRGBO(255, 187, 0, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                        isHost=false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder) => ClientPage()),
                      );
                    },
                    child: const Text(
                      "USER",
                      style: TextStyle(
                        color: Color.fromRGBO(255, 187, 0, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
