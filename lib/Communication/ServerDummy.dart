import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bingo_n/Communication/NetworkData.dart';
import 'package:bingo_n/DTOs/Client.dart';
import 'package:bingo_n/DTOs/ClientSendDto.dart';
import 'package:bingo_n/DTOs/ServerSendDto.dart';
import 'package:bingo_n/Roles/host.dart';

class Server {
  late RawDatagramSocket udpSoket;
  final net = NetworkData.instance;
  late String ip;
  late int tcpPort;
  late int udpPort;
  late String udpTag;
  late Map<Socket,int> clients;
  late ServerSocket serverSocket;
  late  ServerSendDto gameData;
  late Map<int,String> clientsWithId;
  late Map<int,bool> isPlayerReady;
  late List<int> readyPlayers;
  late List<int>wonList;
  int turnId=0;
  late Timer becon;

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
    becon=Timer.periodic(const Duration(seconds: 1), (_) {
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
    Client? client;
    ClientSendDto clientSendDto;
    Map<String,dynamic> json;
    clients.update(clientSocket,(value)=>clients.length,ifAbsent:()=>clients.length);
    client!.setClientSocket(clientSocket);
    int id=clients[clientSocket]!;
    final clientPattern = await generatePattern(id);
    ServerSendDto gameDataLocal=ServerSendDto(gameStarted: false,playersWithId: clientsWithId,readyPlayers: getReadyPlayers());
    final sub=clientSocket.lines.listen(
      (line){
      json=jsonDecode(line);
      clientSendDto=ClientSendDto.fromJson(json);

      clientSendDto.id=clientSendDto.id?? id;
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
      clients.remove(clientSocket);
      clientSocket.destroy();
      _handleTheRemovalOfTheClient(id);
    },
    onDone: () {
      clients.remove(clientSocket);
      clientSocket.destroy();
      _handleTheRemovalOfTheClient(id);
    },
    cancelOnError: true
    );
    net.cancelOn(sub, (){
      clients.remove(clientSocket);
      clientSocket.destroy();
      _handleTheRemovalOfTheClient(id);
    });

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
  void _sendGameDataToASingleClient(Socket clientSocket,ServerSendDto gameDataLocal){

  }
  void _sendGameDataToAllTheClients(){

  }
  void dispose(){
    becon.cancel();
    udpSoket.close();
    for(Socket clientSocet in clients.keys){
      clientSocet.close();
    }
    serverSocket.close();
  }
  int? getKeyByValue(Map<int,Socket> map,Socket value){
    for(int key in map.keys){
      if(map[key]==value){
        return key;
      }
    }
  }
}
