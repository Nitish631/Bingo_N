import 'dart:io';

class Client {
  late Socket clientSocket;
  late String name;
  late bool isReadyToPlay;
  late bool hasWon;
  final int id;
  late List<int> pattern;
  late bool gotPattern;

  Client({
    required this.clientSocket,
    required this.name,
    required this.hasWon,
    required this.isReadyToPlay,
    required this.id,
    required this.gotPattern,
    required this.pattern
  });
  Client.minimal({required this.id});
  void setClientSocket(Socket socket){
    clientSocket=socket;
  }

  @override
  bool operator ==(Object other){
    if(identical(this, other)) return true;
    if(other is!Client) return false;
    return id==other.id;
  }
  @override
  int get hashCode=>id.hashCode;
}
