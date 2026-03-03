import 'package:bingo_n/DTOs/PatternWithId.dart';
import 'package:bingo_n/GameData/MessageType.dart';

class ServerSendDto {
  Map<int, String> playersWithId;
  bool gameStarted;
  List<int> readyPlayers;
  List<int>? gameClickedPattern;
  List<int>? wonList;
  int? turnId;
  PatternWithId clientIdWithPattern=PatternWithId(id: -1, pattern: List.empty()); // client-specific pattern
  int recentlyClicked=-11;
  MessageType messageType=MessageType.automatic;

  ServerSendDto({
    required this.playersWithId,
    required this.readyPlayers,
    required this.gameStarted,
    this.gameClickedPattern,
    this.wonList,
    this.turnId,
    required this.clientIdWithPattern
  });

  void setPlayersWithId(Map<int, String> map) {
    playersWithId
      ..clear()
      ..addAll(map);
  }
  void clear(){
    playersWithId.clear();
    gameStarted=false;
    readyPlayers=[];
    gameClickedPattern=null;
    wonList=null;
    turnId=-1;
    clientIdWithPattern=PatternWithId(id: -1, pattern: List.empty());
  }

  Map<String, dynamic> toJson() {
    return {
      'playersWithId': playersWithId.map((k, v) => MapEntry(k.toString(), v)),
      'gameClickedPattern': gameClickedPattern,
      'playerPattern': clientIdWithPattern.toJson(), 
      'wonList': wonList,
      'turnId': turnId,
      'gameStarted': gameStarted,
      'readyPlayers': readyPlayers,
    };
  }

  factory ServerSendDto.fromJson(Map<String, dynamic> json) {
    return ServerSendDto(
      playersWithId: (json['playersWithId'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(int.parse(k), v as String)),
      readyPlayers: List<int>.from(json['readyPlayers'] ?? []),
      gameStarted: json['gameStarted'] as bool? ?? false,
      gameClickedPattern: json['gameClickedPattern'] != null
          ? List<int>.from(json['gameClickedPattern'])
          : null,
      clientIdWithPattern: json['playerPattern'] != null
          ? PatternWithId.fromJson(json['playerPattern'])
          : PatternWithId(id: -1, pattern: List.empty()),
      wonList: json['wonList'] != null
          ? List<int>.from(json['wonList'])
          : null,
      turnId: json['turnId'] as int?,
    );
  }
}
