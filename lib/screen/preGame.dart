import 'package:bingo_n/database/userInfo.dart';
import 'package:bingo_n/screen/RolePage.dart';
import 'package:bingo_n/screen/nameInput.dart';
import 'package:flutter/material.dart';
class PreGamePage extends StatefulWidget {
  const PreGamePage({super.key});

  @override
  State<PreGamePage> createState() => _PreGamePageState();
}

class _PreGamePageState extends State<PreGamePage> {
  String? name;
  @override
  void initState() {
    _loadUser();
    super.initState();
  }
   Future<void>_loadUser()async{
    final userData=UserDatabase.instance;
    name=await userData.getUserName();      
    setState((){});
   }
  @override
  Widget build(BuildContext context) {
    if(!(name==null)){
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