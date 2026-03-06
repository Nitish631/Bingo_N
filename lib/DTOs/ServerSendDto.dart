import 'package:bingo_n/DTOs/PatternWithId.dart';
import 'package:bingo_n/DTOs/navData.dart';
import 'package:bingo_n/GameData/MessageType.dart';

class ServerSendDto {
  Map<int, String> playersWithId;
  Navdata currentPage = Navdata.lobby;
  List<int> readyPlayers;
  List<int>? gameClickedPattern;
   int wonId;
  int? turnId;
  PatternWithId clientIdWithPattern = PatternWithId(
    id: -1,
    pattern: [],
  ); // client-specific pattern
  int recentlyClicked = -11;
  MessageType messageType = MessageType.automatic;

  ServerSendDto({
    required this.playersWithId,
    required this.readyPlayers,
    required this.currentPage,
    this.gameClickedPattern,
    required this.wonId,
    this.turnId,
    required this.clientIdWithPattern,
    required this.messageType,
  });

  void setPlayersWithId(Map<int, String> map) {
    playersWithId
      ..clear()
      ..addAll(map);
  }

  void clear() {
    playersWithId.clear();
    readyPlayers = [];
    gameClickedPattern = null;
    turnId = -1;
    clientIdWithPattern = PatternWithId(id: -1, pattern: List.empty());
  }

  Map<String, dynamic> toJson() {
    return {
      'playersWithId': playersWithId.map((k, v) => MapEntry(k.toString(), v)),
      'gameClickedPattern': gameClickedPattern,
      'playerPattern': clientIdWithPattern.toJson(),
      'wonId': wonId,
      'turnId': turnId,
      'currentPage': currentPage.toJson(),
      'readyPlayers': readyPlayers,
      'messageType': messageType.toJson(),
    };
  }

  factory ServerSendDto.fromJson(Map<String, dynamic> json) {
    return ServerSendDto(
      playersWithId: (json['playersWithId'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(int.parse(k), v as String),
      ),
      readyPlayers: List<int>.from(json['readyPlayers'] ?? []),
      currentPage: Navdata.fromJson(json['currentPage'] as String? ?? '') ,
      gameClickedPattern: json['gameClickedPattern'] != null
          ? List<int>.from(json['gameClickedPattern'])
          : null,
      clientIdWithPattern: json['playerPattern'] != null
          ? PatternWithId.fromJson(json['playerPattern'])
          : PatternWithId(id: -1, pattern: List.empty()),
      wonId: json['wonId'] as int? ?? -42 ,
      turnId: json['turnId'] as int?,
      messageType: MessageType.fromJson(json['messageType']),
    );
  }
}
