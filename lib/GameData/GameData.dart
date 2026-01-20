import 'package:bingo_n/GameData/ConnectionStatus.dart';
import 'package:flutter/material.dart';

class GameData extends ChangeNotifier {
  late Map<int, String> playersWithId;
  bool gameStarted = false;
  late List<int> readyPlayers;
  late List<int> gameClickedPattern = [];
  late List<int> wonList;
  late int turnId;
  late List<int> myPattern;
  int? _myId;
  late String name;
  bool showReconnectButton = false;
  bool goBackToLobby = false;
  List<int> indexesOfWonPatternMatched=[];
  late ConnectionStatus connectionStatus = ConnectionStatus.instance;

  static final GameData instance = GameData._init();
  GameData._init();

final List<List<int>> winningList = [
  [0, 1, 2, 3, 4],
  [5, 6, 7, 8, 9],
  [10, 11, 12, 13, 14],
  [15, 16, 17, 18, 19],
  [20, 21, 22, 23, 24],
  [0, 5, 10, 15, 20],
  [1, 6, 11, 16, 21],
  [2, 7, 12, 17, 22],
  [3, 8, 13, 18, 23],
  [4, 9, 14, 19, 24],
  [0, 6, 12, 18, 24],
  [4, 8, 12, 16, 20],
];
  void setPlayersWithId(Map<int, String> map) {
    if (!gameStarted) {
      playersWithId
        ..clear()
        ..addAll(map);
    }
  }

  int get myId => _myId!;
  void setId(int? id) {
    _myId ??= id;
  }

  void setName(String? Name) {
    if (!(Name == null)) {
      name = Name;
    }
  }

  void clear() {
    playersWithId.clear();
    gameStarted = false;
    readyPlayers = [];
    gameClickedPattern = [];
    wonList = [];
    turnId = -1;
    myPattern = [];
    _myId = null;
    showReconnectButton = false;
    goBackToLobby = false;
    connectionStatus.reset();
    notifyListeners();
  }

  void notifyUI() {
    notifyListeners();
  }

  List<int> updateGameClickedPattern(int clicked) {
    if (!gameClickedPattern.contains(clicked)) {
      gameClickedPattern.add(clicked);
    }
    return gameClickedPattern;
  }
  void addWonPlayer(id){
    if(!wonList.contains(id)){
      wonList.add(id);
    }
  }
  void calculateWon(){
    //CALCULATE IF YOU WON
    if(!gameStarted)return;
    if(wonList.contains(_myId)) return;
    if(indexesOfWonPatternMatched.length==5){
      wonList.add(_myId!);
      return;
    }
    bool matched=true;
    for(List<int> matchedPattern in winningList){
      if(indexesOfWonPatternMatched.length>=5)break;
      if(indexesOfWonPatternMatched.contains(winningList.indexOf(matchedPattern))) continue;
      matched=true;
      for(int element in matchedPattern){
        if(!gameClickedPattern.contains(element)){
          matched=false;
          break;
        }
      }
      if(matched){
        indexesOfWonPatternMatched.add(winningList.indexOf(matchedPattern));
      }
    }
    if(indexesOfWonPatternMatched.length>=5){
      wonList.add(_myId!);
    }

  }
}
