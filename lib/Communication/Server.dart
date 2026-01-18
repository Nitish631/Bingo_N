import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bingo_n/Communication/NetworkData.dart';
import 'package:bingo_n/DTOs/ClientData.dart';
import 'package:bingo_n/DTOs/ClientSendDto.dart';
import 'package:bingo_n/DTOs/PatternWithId.dart';
import 'package:bingo_n/DTOs/ServerSendDto.dart';
import 'package:bingo_n/Extensions/TcpExtension.dart';

class Server {
  late Timer becon;
  // late Timer gameDataSendingTimer;
  late RawDatagramSocket udpSocket;
  final net = NetworkData.instance;
  late StreamSubscription sub;
  late String ip;
  late int tcpPort;
  late int udpPort;
  late String udpTag;
  late ServerSocket serverSocket;
  late Set<ClientData> clients=<ClientData>{};
  List<int> gameClickedPattern = [];
  bool gameStarted = false; //CHANGE LATER FROM UI
  late List<int> turnPattern;
  int turnId = -1;
  Map<int, String> getClientsWithId() {
    Map<int, String> nameWithId = {};
    for (ClientData client in clients) {
      nameWithId[client.id] = client.name;
    }
    return nameWithId;
  }

  List<int> getReadyPlayers() {
    List<int> list = [];
    for (ClientData client in clients) {
      if (client.isReadyToPlay) {
        list.add(client.id);
      }
    }
    return list;
  }

  List<int> updateGameClickedPattern(int clicked) {
    gameClickedPattern.add(clicked);
    return gameClickedPattern;
  }

  List<int> getWonList() {
    List<int> list = [];
    for (ClientData client in clients) {
      if (client.hasWon) {
        list.add(client.id);
      }
    }
    return list;
  }

  int getNextTurn() {
    int index = turnPattern.indexOf(turnId);
    if (index == (turnPattern.length - 1)) {
      turnId = turnPattern.elementAt(0);
      return turnId;
    }
    turnId = turnPattern.elementAt(++index);
    return turnId;
  }

  List<int> makeTurnPattern() {
    List<int> list = [];
    for (ClientData client in clients) {
      list.add(client.id);
    }
    turnPattern = list;
    return list;
  }

  int getTurnIdOnClientCommunicationError(int id) {
    int index = turnPattern.indexOf(id);
    int length = turnPattern.length;
    turnPattern.remove(id);
    if (index == (length - 1)) {
      if(turnPattern.length==0){
        turnId=-1;
        return turnId;
      }
      turnId = turnPattern.elementAt(0);
    } else {
      turnId = turnPattern.elementAt(index);
    }
    return turnId;
  }

  List<int> generatePattern(int id) {
    return List.empty();
  }

  Future<void> start() async {
    ip = await net.getLocalIPv4();
    tcpPort = net.tcpPort;
    udpPort = net.udpPort;
    udpTag = net.udpTag;
    ClientData client=ClientData.minimal(id: 0);
    clients.add(client);
    await startTCP(tcpPort);
    await UDPBroadCaster(ip, tcpPort, udpTag, udpPort);
  }

  Future<void> UDPBroadCaster(
    String ip,
    int tcpPort,
    String udpTag,
    int udpPort,
  ) async {
    udpSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
      reusePort: true,
      reuseAddress: true,
    );
    udpSocket.broadcastEnabled = true;
    String msg = '${udpTag}|$ip|$tcpPort';
    becon = Timer.periodic(const Duration(seconds: 1), (_) {
      udpSocket.send(
        utf8.encode(msg),
        InternetAddress('255.255.255.255'),
        udpPort,
      );
    });
  }

  Future<void> startTCP(int tcpPort) async {
    serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, tcpPort);
    serverSocket.listen(_handleNewClient);
  }

  Future<void> _handleNewClient(Socket clientSocket) async {
    int id = clientSocket.hashCode;
    ClientData client = ClientData.minimal(id: id);
    clients.add(client);
    ClientSendDto clientSendDto;
    Map<String, dynamic> json;
    List<int> clientGamePattern = generatePattern(id);
    sub = clientSocket.lines.listen(
      (line) {
        json = jsonDecode(line);
        clientSendDto = ClientSendDto.fromJson(json);
        id = clientSendDto.id ?? id;
        client.name = clientSendDto.name;
        client.hasWon = clientSendDto.isWon;
        client.isReadyToPlay = clientSendDto.isReady;
        client.gotPattern = clientSendDto.gotPattern;
        client.pattern = clientGamePattern;
        sendPatternToAllTheClientWhoHaventGot();
        updateGameClickedPattern(clientSendDto.recentlyClicked!);
        getNextTurn();
        //HANDLE THE SERVER PLAYER
        _sendGameDataToAllTheClients();
      },
      onError: (error) {
        _handleTheRemovalOfTheClient(clientSocket, id);
      },
      onDone: () {
        _handleTheRemovalOfTheClient(clientSocket, id);
      },
      cancelOnError: true,
    );
    net.cancelOn(sub, () {
      _handleTheRemovalOfTheClient(clientSocket, id);
    });
  }

  void _handleTheRemovalOfTheClient(Socket clientsocket, int id) {
    clients.removeWhere((client)=>client.clientSocket==clientsocket);
    clientsocket.destroy();
    getTurnIdOnClientCommunicationError(id);
    _sendGameDataToAllTheClients();
  }

  void sendPatternToAllTheClientWhoHaventGot() {
    if (!gameStarted) {
      ServerSendDto serverSendDto = ServerSendDto(
        playersWithId: getClientsWithId(),
        readyPlayers: getReadyPlayers(),
        gameStarted: gameStarted,
      );
      List<int> pattern;
      for (ClientData client in clients) {
        if(client.id==0)continue;
        if (!client.gotPattern) {
          pattern = generatePattern(client.id);
          serverSendDto.clientIdWithPattern = PatternWithId(
            id: client.id,
            pattern: pattern,
          );
          serverSendDto.gamePattern = gameClickedPattern;
          serverSendDto.wonList = getWonList();
          Map<String, dynamic> messageJson = serverSendDto.toJson();
          sendMessage(messageJson);
        }
      }
    }
  }

  void _sendGameDataToAllTheClients() {
    ServerSendDto serverSendDto = ServerSendDto(
      playersWithId: getClientsWithId(),
      readyPlayers: getReadyPlayers(),
      gameStarted: gameStarted,
      gamePattern: gameClickedPattern,
      wonList: getWonList(),
      turnId: turnId,
    );
    Map<String, dynamic> messageJson = serverSendDto.toJson();
    sendMessage(messageJson);
  }

  void sendMessage(Map<String, dynamic> messageJson) {
    String msg = jsonEncode(messageJson);
    for (ClientData client in clients) {
      if(client.id==0)continue;
      try {
        client.clientSocket.write('$msg\n');// client.clientSocket.add(utf8.encode('$msg\n'));
      } catch (error) {
        _handleTheRemovalOfTheClient(client.clientSocket, client.id);
      }
    }
  }

  stopScanningDevices() {
    becon.cancel();
    udpSocket.close();
  }

  stopCommunication() {
    stopScanningDevices();
    for (ClientData client in clients) {
      client.clientSocket.destroy();
    }
    sub.cancel();
    serverSocket.close();
    clients.clear();
  }
  void handleTheServerPlayer(){
    
  }
}
