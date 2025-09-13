import 'package:bingo_n/screen/preGame.dart';
import 'package:flutter/material.dart';
class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _NamePageState();
}
double opacityForSecond(double value){
  if(value<=140){
    return value/140;
  }else if(value>140 && value<=240){
    return (240-value)/100;
  }else{
    return 0;
  }
}
double opacityForFirst(double value){
  if(value<=290)return 0; 
  return 1;
  // return (400-value)/150;
}
class _NamePageState extends State<EntryPage> {
  @override
  Widget build(BuildContext context) {
    return  Container(
      height: double.infinity,
      color: Colors.black,
      width: double.infinity,
      child:Center(
        child:TweenAnimationBuilder(
          tween: Tween<double>(begin: 40,end: 400),
          duration:const Duration(seconds: 5),
          onEnd: () {
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>PreGamePage()));
          } ,
          builder:(context,value,child){
            return Stack(
              children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    
                    children: [
                      Text("B",style: TextStyle(color: Color.fromRGBO(255, 140, 0, opacityForFirst(value)),fontSize: 50,fontWeight: FontWeight.bold,decoration: TextDecoration.none),),
                      Text("I",style: TextStyle(color: Color.fromRGBO(255, 140, 0, opacityForFirst(value)),fontSize: 50,fontWeight: FontWeight.bold,decoration: TextDecoration.none)),
                      Text("N",style: TextStyle(color: Color.fromRGBO(255, 0, 0, opacityForFirst(value)),fontSize: 65,fontWeight: FontWeight.bold,decoration: TextDecoration.none)),
                      Text("G",style: TextStyle(color: Color.fromRGBO(255, 140, 0, opacityForFirst(value)),fontSize: 50,fontWeight: FontWeight.bold,decoration: TextDecoration.none)),
                      Text("O",style: TextStyle(color: Color.fromRGBO(255, 140, 0, opacityForFirst(value)),fontSize: 50,fontWeight: FontWeight.bold,decoration: TextDecoration.none)),
                    ],
                  ),
                Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("B",style: TextStyle(color: Color.fromRGBO(255, 140, 0, opacityForSecond(value)),fontSize: 50,fontWeight: FontWeight.bold,decoration: TextDecoration.none),),
                      Text("I",style: TextStyle(color: Color.fromRGBO(255, 140, 0, opacityForSecond(value-10)),fontSize: 50,fontWeight: FontWeight.bold,decoration: TextDecoration.none)),
                      Text("N",style: TextStyle(color: Color.fromRGBO(255, 0, 0, opacityForSecond(value-20)),fontSize: 65,fontWeight: FontWeight.bold,decoration: TextDecoration.none)),
                      Text("G",style: TextStyle(color: Color.fromRGBO(255, 140, 0, opacityForSecond(value-30)),fontSize: 50,fontWeight: FontWeight.bold,decoration: TextDecoration.none)),
                      Text("O",style: TextStyle(color: Color.fromRGBO(255, 140, 0, opacityForSecond(value-40)),fontSize: 50,fontWeight: FontWeight.bold,decoration: TextDecoration.none)),
                    ],
                  )

              ],
              
            );
          }
        ),
      ),
    );
  }
}