import 'package:bingo_n/GameState/state.dart';
import 'package:flutter/material.dart';
import 'package:bingo_n/main.dart';
import 'package:google_fonts/google_fonts.dart';
class Gamingpage extends StatefulWidget {
  const Gamingpage({super.key});

  @override
  State<Gamingpage> createState() => _GamingpageState();
}

class _GamingpageState extends State<Gamingpage> {
  List<int>pattterrn=List.generate(25, (index)=>index+1);
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
              Color.fromRGBO(170, 0, 255, 1)
            ]
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
                fontWeight: FontWeight.bold,
                color: Colors.deepOrangeAccent
              ),
            ),
            const SizedBox(height: 20,),
            Container(
              height: 500,
              width: 500,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
                itemCount: 25,
                itemBuilder: (context,index){
                  return Container(
                    margin: EdgeInsets.all(2),
                    color: Colors.cyanAccent,
                    decoration: BoxDecoration(
                      border: Border.all(width: 2,color: Colors.brown)
                    ),
                    child: TextButton(
                      onPressed: (){

                      },
                      child: Text(
                        "${pattterrn[index]}",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown
                        ),
                      ),
                    ),
                  );
                },
              ),
            )

          ],
        ),
      ),
    );
  }
}