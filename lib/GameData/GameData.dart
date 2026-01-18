class GameData {
  late Map<int, String> playersWithId;
  bool gameStarted=false;
  late List<int> readyPlayers;
  late List<int> gameClickedPattern;
  late List<int> wonList;
  late int turnId;
  late List<int> myPattern;
  int? _myId;

  static final GameData instance = GameData._init();
  GameData._init();

  void setPlayersWithId(Map<int, String> map) {
    if (!gameStarted) {
      playersWithId
        ..clear()
        ..addAll(map);
    }
  }
  int get myId =>_myId!;
  void setId(int? id){
    _myId ??= id;
  }
  void clear(){
    playersWithId.clear();
    gameStarted=false;
    readyPlayers=[];
    gameClickedPattern=[];
    wonList=[];
    turnId=-1;
    myPattern=[];
    _myId=null;
  }

  List<int> updateGameClickedPattern(int clicked) {
    gameClickedPattern.add(clicked);
    return gameClickedPattern;
  }
}