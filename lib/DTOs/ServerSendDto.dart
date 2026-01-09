class ServerSendDto {
  Map<int, String> playersWithId;
  List<int> gamePattern;
  List<int>? wonList;
  int turnId;
  ServerSendDto({
    required this.gamePattern,
    required this.turnId,
    this.wonList,
    required this.playersWithId,
  });
  Map<String, dynamic> toJson() {
    return {
      'playersWithId': playersWithId,
      'gamePattern': gamePattern,
      'wonList': wonList,
      'turnId': turnId,
    };
  }

  factory ServerSendDto.fromJson(Map<String, dynamic> json) {
    return ServerSendDto(
      gamePattern: json['gamePattern'],
      turnId: json['turnId'],
      playersWithId: json['playersWithId'],
      wonList: json['wonList']
    );
  }
}
