import 'dart:io';

class ClientData {
  late Socket clientSocket;
  late String name;
  late bool isReadyToPlay;
  bool hasWon =false;
  final int id;
  late List<int> pattern;
  late bool gotPattern;
  late int noOfPatternMatched;

  ClientData({
    required this.clientSocket,
    required this.name,
    required this.hasWon,
    required this.isReadyToPlay,
    required this.id,
    required this.gotPattern,
    required this.pattern,
    required this.noOfPatternMatched
  });
  ClientData.minimal({required this.id});
  void setClientSocket(Socket socket){
    clientSocket=socket;
  }

  @override
  bool operator ==(Object other){
    if(identical(this, other)) return true;
    if(other is!ClientData) return false;
    return id==other.id;
  }
  @override
  int get hashCode=>id.hashCode;
}
