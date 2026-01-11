class GameServerData{
  late Map<int,String> playersWithId;
  late List<int> readyPlayers;
  late List<int> gamePattern;
  late List<int> wonList;
  late bool gameStarted;
  late int turnId;
  void setPlayersWithId(Map<int,String> map){
    playersWithId.clear();
    playersWithId.addAll(map);
  }
}
class NetworkDataForClient{
  late String serverIpAddress;
  late int serverPort;
  static NetworkDataForClient instance=NetworkDataForClient._init();
  NetworkDataForClient._init();
}