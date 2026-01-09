import 'dart:collection';

class GameData{
  late HashMap<int,String> playersWithId;
  late List<int> gamePattern;
  late List<int> wonList;
  late int turnId;
  static GameData instance =GameData._init();
  GameData._init();
}
class NetworkDataForClient{
  late int serverIpAddress;
  late int serverPort;
  static NetworkDataForClient instance=NetworkDataForClient._init();
  NetworkDataForClient._init();
}