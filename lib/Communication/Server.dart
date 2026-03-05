import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bingo_n/Communication/NetworkData.dart';
import 'package:bingo_n/DTOs/ClientData.dart';
import 'package:bingo_n/DTOs/ClientSendDto.dart';
import 'package:bingo_n/DTOs/PatternWithId.dart';
import 'package:bingo_n/DTOs/ServerSendDto.dart';
import 'package:bingo_n/GameData/GameData.dart';
import 'package:bingo_n/DTOs/navData.dart';
import 'package:bingo_n/Extensions/TcpExtension.dart';
import 'package:bingo_n/GameData/ConnectionStatus.dart';
import 'package:bingo_n/GameData/MessageType.dart';
import 'package:bingo_n/database/userInfo.dart';
import 'package:flutter/material.dart';

class Server {
  Server._privateConstructor();
  late Timer timer;
  late RawDatagramSocket udpSocket;
  late ServerSocket tcpSocket;
  final net = NetworkData.instance;
  late String ip;
  late int tcpPort;
  late int udpPort;
  late String udpTag;
  ClientData serverClient = ClientData.minimal();
  List<int> turnPattern = [];
  List<int> availableIds = List.generate(50, (i) => i + 4);
  static final Server instance = Server._privateConstructor();
  BuildContext? context;
  late Gamedata gameData;
  Set<ClientData> clients = {};
  bool scanningDevicesStopped = false;
  int wonId = -4;
  List<int> gameClickedPattern = [];
  List<int> readyPlayers = [];
  int recentlyClicked = -11;
  Navdata currentPage = Navdata.rolePage;
  int turnId = -1;
  void start(BuildContext context) {
    try {
      dispose();
      currentPage = Navdata.lobby;
      this.context = context;
      gameData = Gamedata.instance;
      gameData.isServer = true;
      _start();
    } catch (e) {
      print("ERROR IN SERVER . CRASHED : $e");
    }
  }
  void sendNavigateToGamingPage(){
    currentPage=Navdata.gamingPage;
    _sendDataToAllClients(MessageType.clicked);
  }

  void sendDataForCommunication() {
    ClientSendDto clientSendDto = ClientSendDto(
      name: gameData.name ?? "HOST",
      isWon: gameData.isWon(),
      isReady: gameData.isReady(),
      gotPattern: gameData.myPattern.isNotEmpty,
      noOfPatternMatched: gameData.indexesOfWonPatternMatched.length,
      messageType: MessageType.clicked,
      recentlyClicked: -11
    );
    clientSendDto
      ..id = gameData.myId
      ..recentlyClicked = recentlyClicked;
    takeActionOnClick(clientSendDto, gameData.myId);
  }
   void updateGameClickedPattern(int num) {
    if (num > 0) {
      if (gameData.turnId == gameData.myId) {
        ClientSendDto clientSendDto = ClientSendDto(
          name: gameData.name ?? "",
          isWon: gameData.isWon(),
          isReady: gameData.isReady(),
          id: gameData.myId,
          gotPattern: gameData.myPattern.isNotEmpty,
          noOfPatternMatched: gameData.indexesOfWonPatternMatched.length,
          messageType: MessageType.automatic,
          recentlyClicked: num
        );
        takeActionOnClick(clientSendDto, gameData.myId);
      }
    }
  }

  void modifyContext(BuildContext context) {
    this.context = context;
  }

  void takeActionOnClick(ClientSendDto clientSendDto, int id) {
    _handleCommunicationForAClient(clientSendDto, id, MessageType.clicked);
  }

  void NavigateTo(Navdata navdata) {
    gameData.currentPage = navdata;
  }

  void _handleCommunicationForAClient(
    ClientSendDto csdto,
    int id,
    MessageType messageType,
  ) {
    id = csdto.id ?? id;
    ClientData client = clients.firstWhere((client) => client.id == id);
    client.name = csdto.name;
    if (!gameData.playersWithId.containsKey(id)) {
      gameData.playersWithId[id] = client.name;
    }
    if (gameData.currentPage == Navdata.gamingPage) {
      stopScanningDevices();
    }
    client.hasWon = csdto.isWon;
    if (csdto.isWon) {
      wonId = csdto.id ?? id;
    }
    client.isReadyToPlay = csdto.isReady;
    client.gotPattern = csdto.gotPattern;
    //client.pattern
    client.noOfPatternMatched = csdto.noOfPatternMatched;
    if (!gameClickedPattern.contains(csdto.recentlyClicked) &&
        csdto.recentlyClicked! > 0) {
      gameClickedPattern.add(csdto.recentlyClicked!);
      recentlyClicked = csdto.recentlyClicked!;
    }
    if (csdto.messageType == MessageType.clicked) {
      getNextTurnId();
    }
    _sendPatternToClient();
    _sendDataToAllClients(messageType);
  }

  List<int> generatePattern(int id) {
    return List.empty();

    ///
  }

  int getNextTurnId() {
    if (turnPattern.isEmpty) {
      turnId = serverClient.id;
      return turnId;
    }
    int index = turnPattern.indexOf(gameData.turnId);
    if (index < 0) return gameData.serverId;
    if (index == (turnPattern.length - 1)) {
      turnId = turnPattern.first;
      return turnId;
    }
    turnId = turnPattern.elementAt(++index);
    return turnId;
  }

  Map<int, String> getClientsWithId() {
    Map<int, String> nameWithId = {};
    if (clients.length == 1) return nameWithId;
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

  void _sendPatternToClient() {
    if (clients.length == 1) return;
    if (gameData.currentPage == Navdata.lobby) {
      ServerSendDto serverSendDto = ServerSendDto(
        playersWithId: getClientsWithId(),
        readyPlayers: getReadyPlayers(),
        currentPage: currentPage,
        clientIdWithPattern: PatternWithId(id: -1, pattern: []),
        messageType: MessageType.automatic,
        wonId: -100,
      );
      serverSendDto.gameClickedPattern = gameClickedPattern;
      serverSendDto.wonId = wonId;
      serverSendDto.messageType = MessageType.automatic;
      serverSendDto.turnId = turnId;
      serverSendDto.recentlyClicked = recentlyClicked;
      List<ClientData> clientsCopy = clients.toList();
      List<int> pattern;
      for (int i = 0; i < clientsCopy.length; i++) {
        ClientData client = clients.elementAt(i);
        if (client.id == serverClient.id) continue;
        if (!client.gotPattern) {
          try {
            pattern = generatePattern(client.id);
            client.pattern = pattern;
            serverSendDto.clientIdWithPattern = PatternWithId(
              id: client.id,
              pattern: client.pattern,
            );
            Map<String, dynamic> messageJson = serverSendDto.toJson();
            sendMessageToClient(client, messageJson);
          } catch (e) {
            gameData
              ..connectionStatus.setStatus(
                Status.disconnected,
                message: "Disconnected",
              )
              ..currentPage = Navdata.rolePage
              ..notifyUI();

            _handleTheRemovalOfTheClient(client.clientSocket, client.id);
          }
        }
      }
    }
  }

  void sendMessageToClient(
    ClientData client,
    Map<String, dynamic> messageJson,
  ) {
    String msg = jsonEncode(messageJson);
    try {
      client.clientSocket.write('$msg\n');
    } catch (e) {
      _handleTheRemovalOfTheClient(client.clientSocket, client.id);
    }
  }

  void _handleTheRemovalOfTheClient(clientSocket, id) {
    clients.removeWhere((client) => client.clientSocket == clientSocket);
    gameData.playersWithId = getClientsWithId();
    gameData.readyPlayers = getReadyPlayers();
    clientSocket.destroy();
    getTurnIdONTurnRemove(id);
    _sendDataToAllClients(MessageType.automatic);
    if (getClientsWithId().length == 1) {
      gameData.currentPage = Navdata.rolePage;
      gameData.connectionStatus.setStatus(
        Status.disconnected,
        message: "Disconnected",
      );
    } else {
      gameData.connectionStatus.setStatus(
        Status.connected,
        message: "Connected",
      );
    }
    gameData.notifyUI();
  }

  int getTurnIdONTurnRemove(int id) {
    int index = turnPattern.indexOf(id);
    if (index < 0) return gameData.turnId;
    int length = turnPattern.length;
    turnPattern.remove(id);
    if (index == (length - 1)) {
      if (turnPattern.isEmpty) {
        gameData.turnId = -1;
        return -1;
      }
      gameData.turnId = turnPattern.first;
    } else {
      gameData.turnId = turnPattern.elementAt(index);
    }
    return gameData.turnId;
  }

  void stopScanningDevices() {
    if (!scanningDevicesStopped) {
      scanningDevicesStopped = true;
      timer.cancel();
      udpSocket.close();
    }
  }

  void removeClient(int id) {
    ClientData? client = clients.firstWhere(
      (client) => client.id == id,
      orElse: () => ClientData.minimal(),
    );
    if (client.id < 0) return;
    _handleTheRemovalOfTheClient(client.clientSocket, id);
  }

  void _sendDataToAllClients(MessageType messageType) {
    for (var client in clients) {
      ServerSendDto serverSendDto = ServerSendDto(
        playersWithId: getClientsWithId(),
        readyPlayers: getReadyPlayers(),
        currentPage: currentPage,
        wonId: wonId,
        clientIdWithPattern: PatternWithId(id: -4, pattern: []),
        messageType: messageType,
      );
      serverSendDto.gameClickedPattern = gameClickedPattern;
      serverSendDto.turnId = turnId;
      serverSendDto.recentlyClicked = recentlyClicked;
      Map<String, dynamic> messageJson = serverSendDto.toJson();
      sendMessage(messageJson);
    }
  }

  void sendMessage(Map<String, dynamic> messageJson) {
    String msg = jsonEncode(messageJson);
    int length = clients.length;
    for (int i = 0; i < length; i++) {
      ClientData client = clients.elementAt(i);
      if (client.id == serverClient.id) {
        _handleServerClient(messageJson);
      }
      try {
        client.clientSocket.write(
          '$msg\n',
        ); // client.clientSocket.add(utf8.encode('$msg\n'));
      } catch (error) {
        _handleTheRemovalOfTheClient(client.clientSocket, client.id);
      }
    }
  }

  void _handleServerClient(Map<String, dynamic> json) {
    ServerSendDto serverSendDto = ServerSendDto.fromJson(json);
    gameData
      ..playersWithId = serverSendDto.playersWithId
      ..currentPage = serverSendDto.currentPage
      ..readyPlayers = serverSendDto.readyPlayers
      ..gameClickedPattern = serverSendDto.gameClickedPattern!
      ..wonId = serverSendDto.wonId
      ..turnId = serverSendDto.turnId!
      ..recentlyClicked = serverSendDto.recentlyClicked
      ..calculateWon();
    if (serverSendDto.messageType == MessageType.clicked) {
      _sendDataAutomaticallyToAllClients();
    }
    gameData.notifyUI();
  }

  void _sendDataAutomaticallyToAllClients() {
    _sendDataToAllClients(MessageType.automatic);
  }

  void dispose() async {
    currentPage = Navdata.rolePage;
    try {
      try {
        timer.cancel();
      } catch (_) {}
      try {
        udpSocket.close();
      } catch (_) {}
      for (ClientData client in clients.toList()) {
        try {
          await client.subscription?.cancel();
        } catch (_) {}

        try {
          await client.clientSocket.close();
        } catch (_) {}
      }
      clients.clear();
      try {
        await tcpSocket.close();
      } catch (_) {}
      serverClient = ClientData.minimal();
      turnPattern = [];
      availableIds = List.generate(50, (i) => i + 4);
      context = null;
      clients = {};
      scanningDevicesStopped = false;
      wonId = -4;
      gameClickedPattern = [];
      readyPlayers = [];
      recentlyClicked = -11;
      currentPage = Navdata.rolePage;
      turnId = -1;
      gameData.clear();
      gameData.notifyUI();
    } catch (_) {}
  }

  void _start() async {
    UserDatabase userDatabase = UserDatabase.instance;
    ip = await net.getLocalIPv4();
    tcpPort = net.tcpPort;
    udpPort = net.udpPort;
    udpTag = net.udpTag;
    String? name = await userDatabase.getUserName();
    serverClient.name = name ?? "HOST";
    int id = availableIds.elementAt(Random().nextInt(availableIds.length - 1));
    serverClient.id = id;
    serverClient.isReadyToPlay = true;
    availableIds.remove(id);
    clients.add(serverClient);
    if (!turnPattern.contains(id)) {
      turnPattern.add(id);
    }
    gameData.playersWithId[id] = serverClient.name;
    gameData.serverId = serverClient.id;
    gameData.myId = serverClient.id;
    gameData.readyPlayers.add(id);
    gameData.name = name;
    gameData.turnId = id;
    gameData.myPattern = generatePattern(id);
    gameData.notifyUI();
    await UDPBroadCaster(ip, tcpPort, udpTag, udpPort);
    await startTCP(tcpPort);
  }

  Future<void> startTCP(int tcpPort) async {
    tcpSocket = await ServerSocket.bind(InternetAddress.anyIPv4, tcpPort);
    tcpSocket.listen(_handleNewClient);
  }

  Future<void> _handleNewClient(Socket clientSocket) async {
    int greatestId = clients.reduce((a, b) => a.id > b.id ? a : b).id;
    ;
    if (availableIds.isEmpty) {
      availableIds = List.generate(100, (i) => i + greatestId + 1);
    }
    if (clients.length > 7) {
      return;
    }
    int id = availableIds.elementAt(Random().nextInt(availableIds.length - 1));
    availableIds.remove(id);
    ClientData client = ClientData.minimal();
    client.id = id;
    client.clientSocket = clientSocket;
    clients.add(client);
    if (!turnPattern.contains(id)) {
      turnPattern.add(id);
    }
    ClientSendDto clientSendDto;
    Map<String, dynamic> json;
    List<int> clientGamePattern = generatePattern(id);
    client.subscription = clientSocket.lines.listen(
      (line) {
        try {
          json = jsonDecode(line);
          clientSendDto = ClientSendDto.fromJson(json);
          _handleCommunicationForAClient(
            clientSendDto,
            id,
            MessageType.automatic,
          );
        } catch (e) {
          _handleTheRemovalOfTheClient(clientSocket, id);
        }
      },
      onError: (error) {
        _handleTheRemovalOfTheClient(clientSocket, id);
      },
      onDone: () {
        _handleTheRemovalOfTheClient(clientSocket, id);
      },
    );
  }

  Future<void> UDPBroadCaster(
    String ip,
    int tcpPort,
    String udpTag,
    int udpPort,
  ) async {
    gameData.connectionStatus.setStatus(
      Status.discovering,
      message: "Scanning Players.",
    );
    gameData.notifyUI();
    udpSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      udpPort,
      reusePort: true,
      reuseAddress: true,
    );
    udpSocket.broadcastEnabled = true;
    String msg = '${udpTag}|$ip|$tcpPort';
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      udpSocket.send(
        utf8.encode(msg),
        InternetAddress('255.255.255.255'),
        udpPort,
      );
    });
  }
}
