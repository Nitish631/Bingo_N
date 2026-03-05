import 'package:bingo_n/GameData/MessageType.dart';

class ClientSendDto {
  int recentlyClicked=-11;
  bool isWon;
  int? id;
  String name="";
  bool isReady;
  bool gotPattern;
  int noOfPatternMatched=0;
  MessageType messageType=MessageType.automatic;

  ClientSendDto({
    required this.name,
    this.id,
    required this.isWon,
    required this.recentlyClicked,
    required this.isReady,
    required this.gotPattern,
    required this.noOfPatternMatched,
    required this.messageType
  });
  ClientSendDto.min({required this.gotPattern,required this.isReady,required this.isWon});
  void clear(){
    recentlyClicked=-11;
    isWon=false;
    id=null;
    name="";
    isReady=false;
    gotPattern=false;
  }

  Map<String, dynamic> toJson() {
    return {
      'recentlyClicked': recentlyClicked,
      'isWon': isWon,
      'id': id,
      'name': name,
      'isReady': isReady,
      'gotPattern': gotPattern,
      'noOfPatternMatched':noOfPatternMatched,
      'messageType':messageType.toJson()
    };
  }

  factory ClientSendDto.fromJson(Map<String, dynamic> json) {
    return ClientSendDto(
      name: json['name'] as String,
      isWon: json['isWon'] as bool,
      id: json['id'] as int?,
      recentlyClicked: json['recentlyClicked'] as int,
      isReady: json['isReady'] as bool,
      gotPattern: json['gotPattern'] as bool,
      noOfPatternMatched: json['noOfPatternMatched'] as int,
      messageType:MessageType.fromJson( json['messageType'])
    );
  }
}
