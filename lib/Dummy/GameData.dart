import 'package:bingo_n/DTOs/PatternWithId.dart';
import 'package:bingo_n/Dummy/navData.dart';
import 'package:bingo_n/GameData/ConnectionStatus.dart';
import 'package:flutter/material.dart';

class Gamedata extends ChangeNotifier {
  Gamedata._privateConstructor();
  static final Gamedata instance = Gamedata._privateConstructor();
  Navdata currentPage = Navdata.rolePage;
  bool isServer=false;
  int wonId=-4;
  int myId=-3;
  int turnId=-1;
  int recentlyClicked=-11;
  int serverId=-22;
  String? name;
  List<int>myPattern=[];
  int count=0;
  Map<int,String>matchingCharacter={};
  List<int> indexesOfWonPatternMatched=[];
  ConnectionStatus connectionStatus = ConnectionStatus.instance;  
  Map<int, String> playersWithId = {};
  List<int> gameClickedPattern = [];
  List<int> readyPlayers = [];
  List<String> matchingString = ['B', 'I', 'N', 'G', 'O'];
  bool showReconnectButton=false;

  final List<List<int>> winningList = [
    [0, 1, 2, 3, 4], //0
    [5, 6, 7, 8, 9], //1
    [10, 11, 12, 13, 14], //2
    [15, 16, 17, 18, 19], //3
    [20, 21, 22, 23, 24], //4
    [0, 5, 10, 15, 20], //5
    [1, 6, 11, 16, 21], //6
    [2, 7, 12, 17, 22], //7
    [3, 8, 13, 18, 23], //8
    [4, 9, 14, 19, 24], //9
    [0, 6, 12, 18, 24], //10
    [4, 8, 12, 16, 20], //11
  ];
  void setMyPattern(PatternWithId patternWithId){
    if(patternWithId.id>0){
      myPattern=patternWithId.pattern;
      myId=patternWithId.id;
    }
  }
    String getCharIfPatternMatched(int patternIndex) {
    if (indexesOfWonPatternMatched.contains(patternIndex)) {
      String? char = matchingCharacter[patternIndex];
      if (char != null) {
        return char;
      }
    }
    return "";
  }
  bool isClicked(int num){
    return gameClickedPattern.contains(num);
  }
  bool isMyTurn(){
    return turnId==myId;
  }
   bool isReady()=>readyPlayers.contains(myId);
  void clear(){
    playersWithId.clear();
    wonId=-4;
    myId=-3;
    turnId=-1;
    gameClickedPattern.clear();
    readyPlayers.clear();
    recentlyClicked=-11;
    serverId=-22;
    myPattern.clear();
    isServer=false;
  }
  void updateClickedPattern(int clicked){
    if(clicked<0)return;
    if(gameClickedPattern.contains(clicked))return;
    recentlyClicked=clicked;
    gameClickedPattern.add(clicked);
  }
  bool isPlayerReady(int id){
    return readyPlayers.contains(id);
  }
  bool isTurnOf(int id){
    return turnId==id;
  }
  void calculateWon(){
//CALCULATE IF YOU WON
    if (currentPage!=Navdata.gamingPage) return;
    if (wonId>0) return;
    if (indexesOfWonPatternMatched.length >= 5) {
      wonId = myId;
      return;
    }
    bool matched = true;
    int num;
    for (List<int> matchedPattern in winningList) {
      if (indexesOfWonPatternMatched.length >= 5) break;
      if (indexesOfWonPatternMatched.contains(
        winningList.indexOf(matchedPattern),
      ))
        continue;
      matched = true;
      for (int element in matchedPattern) {
        try {
          num = int.parse(getElementOfIndexOfMyPattern(element));
        } catch (e) {
          num = -1;
        }
        if (!gameClickedPattern.contains(num)) {
          matched = false;
          break;
        }
      }
      if (matched) {
        indexesOfWonPatternMatched.add(winningList.indexOf(matchedPattern));
        matchingCharacter[winningList.indexOf(matchedPattern)] = matchingString
            .elementAt(count);
        count++;
      }
    }
    if (indexesOfWonPatternMatched.length >= 5) {
      wonId = myId;
    }
  }
    String getElementOfIndexOfMyPattern(int index) {
    try {
      return myPattern.elementAt(index).toString();
    } catch (e) {
      return "";
    }
  }

  int noOfNotReadyPlayers(){
    int count = 0;
    playersWithId.forEach((key, value) {
      if (!readyPlayers.contains(key)) {
        count++;
      }
    });
    return count;
  }
  bool isWon(){
    return wonId==myId;
  }

  void notifyUI(){
    notifyListeners();
  }
}