class ClientSendDto {
  int? recentlyClicked;
  bool isWon;
  int? id;
  String name;
  bool isReady;
  ClientSendDto({
    required this.name,
    this.id,
    required this.isWon,
    this.recentlyClicked,
    required this.isReady
  });
  Map<String, dynamic> toJson() {
    return {
      'recentlyClicked': recentlyClicked,
      'isWon': isWon,
      'id': id,
      'name': name,
      'isReady':isReady
    };
  }

  factory ClientSendDto.fromJson(Map<String, dynamic> json) {
    return ClientSendDto(
      name: json['name'],
      isWon: json['isWon'],
      id: json['id'],
      recentlyClicked: json['recentlyClicked'],
      isReady: json['isReady']
    );
  }
}
