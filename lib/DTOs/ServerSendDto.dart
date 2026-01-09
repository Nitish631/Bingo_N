class ServerSendDto {
  Map<int, String> playersWithId;
  List<int> gamePattern;
  List<int>? wonList;
  int turnId;
  bool gameStarted;
  List<int> readyPlayers;
  ServerSendDto({
    required this.gamePattern,
    required this.turnId,
    this.wonList,
    required this.playersWithId,
    required this.readyPlayers,
    required this.gameStarted
  });
  Map<String, dynamic> toJson() {
    return {
      'playersWithId': playersWithId,
      'gamePattern': gamePattern,
      'wonList': wonList,
      'turnId': turnId,
      'gameStarted':gameStarted,
      'readyPlayers':readyPlayers
    };
  }

  factory ServerSendDto.fromJson(Map<String, dynamic> json) {
    return ServerSendDto(
      gamePattern: json['gamePattern'],
      turnId: json['turnId'],
      playersWithId: json['playersWithId'],
      wonList: json['wonList'],
      readyPlayers: json['readyPlayers'],
      gameStarted: json['gameStarted']
    );
  }
}
