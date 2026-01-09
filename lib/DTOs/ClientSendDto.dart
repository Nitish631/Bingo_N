class ClientSendDto {
  int? recentlyClicked;
  bool? isWon;
  int? id;
  String name;
  ClientSendDto({
    required this.name,
    this.id,
    this.isWon,
    this.recentlyClicked,
  });
  Map<String, dynamic> toJson() {
    return {
      'recentlyClicked': recentlyClicked,
      'isWon': isWon,
      'id': id,
      'name': name,
    };
  }

  factory ClientSendDto.fromJson(Map<String, dynamic> json) {
    return ClientSendDto(
      name: json['name'],
      isWon: json['isWon'],
      id: json['id'],
      recentlyClicked: json['recentlyClicked'],
    );
  }
}
