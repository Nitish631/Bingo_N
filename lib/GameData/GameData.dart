import 'dart:math';

import 'package:bingo_n/Communication/Client.dart';
import 'package:bingo_n/Communication/Server.dart';
import 'package:bingo_n/DTOs/ClientSendDto.dart';
import 'package:bingo_n/GameData/ConnectionStatus.dart';
import 'package:bingo_n/database/userInfo.dart';
import 'package:flutter/material.dart';

class GameData extends ChangeNotifier {
  late Map<int, String> playersWithId = {
    101: "Alice",
    205: "Bob",
    309: "Charlie",
    412: "David",
    518: "Emma",
  };
  bool gameStarted = false; //
  List<int> readyPlayers = [518, 412]; //
  List<int> gameClickedPattern = [];
  List<int> wonList = [];
  late int turnId = 205; //
  List<int> myPattern = [
    23,
    16,
    7,
    11,
    20,
    10,
    5,
    12,
    4,
    17,
    19,
    15,
    1,
    21,
    22,
    6,
    2,
    14,
    3,
    24,
    13,
    25,
    8,
    9,
    18,
  ];
  List<int> indexClickedPattern = [];
  int _myId = 205; //
  // late String name;//
  String name = "Bob";
  bool showReconnectButton = false;
  bool goBackToLobby = false;
  List<int> indexesOfWonPatternMatched = [];
  Map<int, String> matchingCharacter = {};
  List<String> matchingString = ['B', 'I', 'N', 'G', 'O'];
  int count = 0;
  late ConnectionStatus connectionStatus = ConnectionStatus.instance;
  bool isServer = false;
  int recentlyClicked = -11;
int wonId=205;
  static final GameData instance = GameData._init();
  GameData._init();
  UserDatabase userDatabase = UserDatabase.instance;
  bool storedPattern = false;
  Server? _server;
  Client? _client;
  void attachServer(Server server) {
    _server = server;
  }

  void attachClient(Client client) {
    _client = client;
  }

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
  void setPlayersWithId(Map<int, String> map) {
    if (!gameStarted) {
      playersWithId
        ..clear()
        ..addAll(map);
    }
  }

  int get myId => _myId!;
  void setId(int? id) {
    _myId =id??0;
  }

  void hasWon(){
    if(wonList.length!=0){
      wonId= wonList.elementAt(0);
      notifyListeners();
    }
  }

  List<int> alterPattern(List<int> list) {
    List<int> order = [0, 1, 2];
    order.shuffle(Random());
    List<int> pattern = List.empty();
    order.forEach((i) {
      switch (i) {
        case 0:
          for (int i = 15; i >= 8; i--) {
            pattern.add(list.elementAt(i));
          }
          break;
        case 1:
          for (int i = 16; i < 25; i++) {
            pattern.add(list.elementAt(i));
          }
          break;
        case 2:
          for (int i = 7; i >= 0; i--) {
            pattern.add(list.elementAt(i));
          }
          break;
      }
    });
    return pattern;
  }

  Future<void> saveMyPatternToDBifWon() async {
    if (wonList.length != 0) {
      await savePattern();
    }
  }

  Future<void> savePattern() async {
    if (!storedPattern) {
      await userDatabase.updatePattern(alterPattern(myPattern));
      storedPattern = true;
    }
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
    _myId = -1; //
    showReconnectButton = false;
    goBackToLobby = false;
    indexClickedPattern = [];
    connectionStatus.reset();
    recentlyClicked = -11;
    storedPattern = false;
    notifyListeners();
  }

  void notifyUI() {
    notifyListeners();
  }

  void notifyReadyToServer(bool ready) {
    ClientSendDto clientSendDto = ClientSendDto(
      name: name,
      isWon: false,
      isReady: ready,
      id: myId,
      gotPattern: myPattern.isNotEmpty,
      noOfPatternMatched: 0,
    );
    _client?.sendMessageToServer(clientSendDto);
    if (ready) {
      readyPlayers.add(_myId);
    } else {
      readyPlayers.remove(_myId);
    }
    notifyListeners();
  }

  void updateGameClickedPattern(int clicked) {
    if (clicked < 0) return;
    if (!gameClickedPattern.contains(clicked)) {
      gameClickedPattern.add(clicked);
    }
    notifyListeners();
    return;
  }

  void updateGameClickedPatternWithIndexAndNumber(int index, int num) {
    updateGameClickedPattern(num);
    if (index < 0) return;
    if (!indexClickedPattern.contains(index)) {
      indexClickedPattern.add(index);
    }
  }

  void addWonPlayer(id) {
    if (!wonList.contains(id)) {
      wonList.add(id);
    }
    notifyListeners();
  }

  void calculateWon() {
    //CALCULATE IF YOU WON
    if (!gameStarted) return;
    if (wonList.contains(_myId)) return;
    if (indexesOfWonPatternMatched.length >= 5) {
      wonList.add(_myId!);
      saveMyPatternToDBifWon();
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
      wonList.add(_myId!);
      saveMyPatternToDBifWon();
    }
    notifyListeners();
  }

  String getCharIfPatternMatched(int patternIndex) {
    calculateWon();
    if (indexesOfWonPatternMatched.contains(patternIndex)) {
      String? char = matchingCharacter[patternIndex];
      if (char != null) {
        notifyListeners();
        return char;
      }
    }
    notifyListeners();
    return "";
  }

  bool isClicked(int n) {
    if (n < 0) return false;
    return gameClickedPattern.contains(n);
  }

  String getElementOfIndexOfMyPattern(int index) {
    try {
      return myPattern.elementAt(index).toString();
    } catch (e) {
      return "";
    }
  }

  bool isMyTurn() {
    return turnId == myId;
  }

  void sendDataForCommunication() {
    if (isServer) {
      _server!.sendGameDataToAllTheClients();
    } else {
      ClientSendDto clientSendDto = ClientSendDto(
        name: name,
        isWon: wonList.contains(myId),
        isReady: readyPlayers.contains(myId),
        gotPattern: myPattern.isNotEmpty,
        noOfPatternMatched: indexesOfWonPatternMatched.length,
      );
      clientSendDto
        ..id = myId
        ..recentlyClicked = recentlyClicked;
      _client?.sendMessageToServer(clientSendDto);
    }
    notifyListeners();
  }

  void removeClient(int id) {
    if (!isServer) return;
    _server!.removeClient(id);
    playersWithId.remove(id);
    notifyListeners();
    _server!.sendGameDataToAllTheClients();
  }

  int returnNOnReadyPlayersCountWhileStarting() {
    if (!isServer) return 0;
    int count = 0;
    playersWithId.forEach((key, value) {
      if (!readyPlayers.contains(key)) {
        count++;
      }
    });
    if (count == 0) {
      gameStarted = true;
    }
    notifyListeners();
    return count;
  }

  bool isTurnOfId(int id) {
    return turnId == id;
  }

  bool isReadyPlayer(int id) {
    return readyPlayers.contains(id);
  }
}
