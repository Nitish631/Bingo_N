class ClientSendDto {
  int? recentlyClicked;
  bool isWon;
  int? id;
  String name;
  bool isReady;
  bool gotPattern;
  int noOfPatternMatched=0;

  ClientSendDto({
    required this.name,
    this.id,
    required this.isWon,
    this.recentlyClicked,
    required this.isReady,
    required this.gotPattern,
    required this.noOfPatternMatched,
  });
  void clear(){
    recentlyClicked=null;
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
      'noOfPatternMatched':noOfPatternMatched
    };
  }

  factory ClientSendDto.fromJson(Map<String, dynamic> json) {
    return ClientSendDto(
      name: json['name'] as String,
      isWon: json['isWon'] as bool,
      id: json['id'] as int?,
      recentlyClicked: json['recentlyClicked'] as int?,
      isReady: json['isReady'] as bool,
      gotPattern: json['gotPattern'] as bool,
      noOfPatternMatched: json['noOfPatternMatched'] as int
    );
  }
}
