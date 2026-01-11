class ClientSendDto {
  int? recentlyClicked;
  bool isWon;
  int? id;
  String name;
  bool isReady;
  bool gotPattern;
  ClientSendDto({
    required this.name,
    this.id,
    required this.isWon,
    this.recentlyClicked,
    required this.isReady,
    required this.gotPattern
  });
  Map<String, dynamic> toJson() {
    return {
      'recentlyClicked': recentlyClicked,
      'isWon': isWon,
      'id': id,
      'name': name,
      'isReady':isReady,
      'gotPattern':gotPattern
    };
  }

  factory ClientSendDto.fromJson(Map<String, dynamic> json) {
    return ClientSendDto(
      name: json['name'],
      isWon: json['isWon'],
      id: json['id'],
      recentlyClicked: json['recentlyClicked'],
      isReady: json['isReady'],
      gotPattern: json['gotPattern']
    );
  }
}
