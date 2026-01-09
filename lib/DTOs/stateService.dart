import 'dart:convert';

import 'package:bingo_n/boundedSet.dart';

class Stateservice {
  static Stateservice instance=Stateservice._init();
  Stateservice._init();
  String serializeState({String? Name,List<int>? clientPattern,required turn,required int recentSelected,bool? shouldStartGame,bool? isWonGame}){
    String msg="";
    if(Name!=null && clientPattern!=null){
      Map<String,dynamic> firstData={
        'Name':Name,
        'clientPattern':clientPattern,
      };
      msg=jsonEncode(firstData);
    }else{
      Map<String,dynamic> laterData={
        'isMyTurn':turn,
        'recentSelected':recentSelected,
        'isWonGame':isWonGame
      };
      msg=jsonEncode(laterData);
    }
    return msg;
  }
  Map<String,dynamic>deserializeState(String str){
    try{
      final Map<String,dynamic> data=jsonDecode(str);
      return data;
    }catch(e){
      return{};
    }
  }
  List<bool> turn=List.generate(BoundedSet.instance.set.length+1,(c)=>false);
}