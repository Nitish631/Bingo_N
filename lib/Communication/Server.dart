import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bingo_n/Communication/NetworkData.dart';
import 'package:bingo_n/DTOs/ClientSendDto.dart';
import 'package:bingo_n/GameData/GameData.dart';
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
  final GameData gameData=GameData.instance;

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
  void _handleNewClient(Socket clientSocket){
    clients.add(clientSocket);
    final sub=clientSocket.lines.listen((line){
      Map<String,dynamic> json=jsonDecode(line);
      ClientSendDto clientSendDto=ClientSendDto.fromJson(json);
    });
    _sendGameDataToAllTheClients();
    // gameData.playersWithId.addAll({clients.indexOf(clientSocket):''})

  }

  void _sendGameDataToAllTheClients(){

  }
}
