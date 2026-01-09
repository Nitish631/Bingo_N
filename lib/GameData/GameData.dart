class GameData{
  late Map<int,String> playersWithId;
  late List<int> readyPlayers;
  late List<int> gamePattern;
  late List<int> wonList;
  late bool gameStarted;
  late int turnId;
  static GameData instance =GameData._init();

  GameData._init();
}
class NetworkDataForClient{
  late String serverIpAddress;
  late int serverPort;
  static NetworkDataForClient instance=NetworkDataForClient._init();
  NetworkDataForClient._init();
}