import 'package:bingo_n/Service/stateService.dart';
import 'package:bingo_n/database/userInfo.dart';
late final dbInst;
 late List<int> pattern;
  late String hostName;
  late String myName;
  bool isMyTurn=false;
  int gotRecentSelected=55;
  int sendRecentSelected=55;
  bool? isHost;
class GameState{
  Map<String,dynamic> gameData={};
  final service=Stateservice.instance;
  Map<String,dynamic>? userData;
  static GameState?_instance;
  List<String> clientNames=[];
  List<bool>?clientsAlloweded;
  bool hostStartedGame=false;
  GameState._init();
  static Future<GameState> getInstance() async{
    if(_instance==null){
      final instance=GameState._init();
      instance.service.turn.insert(0,true );
      dbInst=await UserDatabase.instance;
      instance.userData=dbInst.getUser();
      _instance=instance;
    }
    return _instance!;
  }
  void setClickedNumber(int num){
    this.setClickedNumber(num);
  }
  Future<bool> updatePattern(List<int> pattern)async{
    return await dbInst.updatePattern(pattern);
  }
  void changeTurn(){
    int currentTurn=service.turn.indexOf(true);
    service.turn[currentTurn]=false;
    service.turn[currentTurn+1]=true;
  }
}