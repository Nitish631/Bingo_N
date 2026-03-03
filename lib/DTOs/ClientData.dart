import 'dart:async';
import 'dart:io';

class ClientData {
  late Socket clientSocket;
  late String name;
  bool isReadyToPlay=false;
  bool hasWon =false;
  late int id;
  late bool gotPattern;
  late int noOfPatternMatched;
  StreamSubscription? subscription;
  List<int> pattern=[];


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
  ClientData.minimal();
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
