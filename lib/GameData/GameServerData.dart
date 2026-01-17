// class GameServerData {
//   late Map<int, String> playersWithId;
//   late List<int> readyPlayers;
//   late List<int> gameClickedPattern;
//   late List<int> wonList;
//   late bool gameStarted;
//   late int turnId;

//   static final  GameServerData instance=GameServerData._init();
//   GameServerData._init();

//   void setPlayersWithId(Map<int, String> map) {
//     playersWithId
//       ..clear()
//       ..addAll(map);
//   }
  
//   List<int> updateGameClickedPattern(int clicked){
//     gameClickedPattern.add(clicked);
//     return gameClickedPattern;
//   }


// }

// class NetworkDataForClient {
//   late String serverIpAddress;
//   late int serverPort;
//   static NetworkDataForClient instance = NetworkDataForClient._init();
//   NetworkDataForClient._init();
// }
