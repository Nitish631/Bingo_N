import 'package:bingo_n/screen/RolePage.dart';
import 'package:bingo_n/screen/nameInput.dart';
import 'package:flutter/material.dart';
import 'package:bingo_n/main.dart';
class PreGamePage extends StatefulWidget {
  const PreGamePage({super.key});

  @override
  State<PreGamePage> createState() => _PreGamePageState();
}

class _PreGamePageState extends State<PreGamePage> {
  String? name;
  @override
  void initState() {
    super.initState();
    _loadUser();
  }
   Future<void>_loadUser()async{
    final userData=gmst.userData;
    setState(() {
     name=userData?['name']??"";      
    });
   }
  @override
  Widget build(BuildContext context) {
    if(name!.isNotEmpty){
      Future.microtask((){
        if(mounted){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Rolepage()));
        }
      });
    }else if(name==null){
      return Scaffold(
        body: Center(child: CircularProgressIndicator(),),
      );
    }
    return NameInputPage();
  }
}