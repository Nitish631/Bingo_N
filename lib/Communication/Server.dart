import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bingo_n/Communication/NetworkData.dart';
import 'package:bingo_n/DTOs/ClientSendDto.dart';
import 'package:bingo_n/GameData/GameServerData.dart';
import 'package:bingo_n/Roles/host.dart';

class Server {
  late RawDatagramSocket udpSoket;
  final net = NetworkData.instance;
  late String ip;
  late int tcpPort;
  late int udpPort;
  late String udpTag;
  late List<Socket> clients;
  late ServerSocket serverSocket;
  late  GameServerData gameData;
  late Map<int,String> clientsWithId;
  late Map<int,bool> isPlayerReady;
  late List<int> readyPlayers;
  late List<int>wonList;
  int turnId=0;
  //DETERMINE FROM THE UI
  bool gameStarted=false;
  Future<void> start() async {
    ip = await net.getLocalIPv4();
    tcpPort = net.tcpPort;
    udpPort = net.udpPort;
    udpTag = net.udpTag;
    await startTCP(tcpPort);
    await UDPBroadCaster(ip, tcpPort, udpTag, udpPort);
  }


  Future<void> UDPBroadCaster(
    String ip,
    int tcpPort,
    String udpTag,
    int udpPort,
  ) async {
    udpSoket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
      reuseAddress: true,
      reusePort: true,
    );
    udpSoket.broadcastEnabled = true;
    final msg = '${udpTag}|$ip|$tcpPort';
    Timer becon=Timer.periodic(const Duration(seconds: 1), (_) {
      udpSoket.send(
        utf8.encode(msg),
        InternetAddress('255.255.255.255'),
        udpPort,
      );
    });
  }
  Future<void> startTCP(int tcpPort)async{
    serverSocket=await ServerSocket.bind(InternetAddress.anyIPv4, tcpPort);
    serverSocket.listen(_handleNewClient);
  }
  void _handleNewClient(Socket clientSocket)async{
    ClientSendDto clientSendDto;
    GameServerData gameDataLocal=GameServerData();
    Map<String,dynamic> json;
    clients.add(clientSocket);
    final clientPattern = await generatePattern(clients.indexOf(clientSocket));
    gameDataLocal.gamePattern=clientPattern;   
    final sub=clientSocket.lines.listen(
      (line){
      json=jsonDecode(line);
      clientSendDto=ClientSendDto.fromJson(json);
      clientSendDto.id=clientSendDto.id?? clients.indexOf(clientSocket);
      clientsWithId.update(clientSendDto.id!,(value)=> clientSendDto.name,ifAbsent: ()=>clientSendDto.name);
      isPlayerReady.update(clientSendDto.id!,(wasReady)=>clientSendDto.isReady);
      clientSendDto.isWon?wonList.add(clientSendDto.id!):null;
      if(!clientSendDto.gotPattern){
        _sendGameDataToASingleClient(clientSocket, gameDataLocal);
      }
      gameData.setPlayersWithId(clientsWithId);
      gameData.readyPlayers=getReadyPlayers();
      gameData.gamePattern=List.empty();
      gameData.wonList=wonList;
      gameData.gameStarted=gameStarted;
      gameData.turnId=turnId;
      _sendGameDataToAllTheClients();

    },
    onError: (error){
      int id=clients.indexOf(clientSocket);
      clients.remove(clientSocket);
      clientSocket.destroy();
      _handleTheRemovalOfTheClient(id);
    },
    onDone: () {
      int id=clients.indexOf(clientSocket);
      clients.remove(clientSocket);
      clientSocket.destroy();
      _handleTheRemovalOfTheClient(id);
    },
    cancelOnError: true
    );

  }
 void _handleTheRemovalOfTheClient(int id) {
  final lastKey = clientsWithId.length;

  for (int key = id; key < lastKey; key++) {
    clientsWithId[key] = clientsWithId[key + 1]!;
    isPlayerReady[key]=isPlayerReady[key+1]!;
  }
  clientsWithId.remove((lastKey-1));
  isPlayerReady.remove(lastKey-1);
  gameData.setPlayersWithId(clientsWithId);
  gameData.readyPlayers=getReadyPlayers();
  _sendGameDataToAllTheClients();
}

  Future<List<int>> generatePattern(int id)async{
    return List.empty();
  }
  List<int> getReadyPlayers(){
    for(var entry in isPlayerReady.entries){
      if(entry.value){
        readyPlayers.add(entry.key);
      }
    }
    return readyPlayers;
  }
  void _sendGameDataToASingleClient(Socket clientSocket,GameServerData gameDataLocal){

  }
  void _sendGameDataToAllTheClients(){

  }
}
