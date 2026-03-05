import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bingo_n/Communication/NetworkData.dart';
import 'package:bingo_n/DTOs/ClientData.dart';
import 'package:bingo_n/DTOs/ClientSendDto.dart';
import 'package:bingo_n/DTOs/PatternWithId.dart';
import 'package:bingo_n/DTOs/ServerSendDto.dart';
import 'package:bingo_n/Extensions/TcpExtension.dart';
import 'package:bingo_n/GameData/ConnectionStatus.dart';
import 'package:bingo_n/GameData/GameData.dart';
import 'package:bingo_n/GameData/MessageType.dart';
import 'package:bingo_n/database/userInfo.dart';
import 'package:flutter/material.dart';

class Server {
  static Server instance = Server._init();
  Server._init() {
    gameData = GameData.instance;
    gameData.attachServer(this);
  }
  bool serverStarted = false;

  List<int> availableId = List.empty();
  late Timer becon;
  late RawDatagramSocket udpSocket;
  final net = NetworkData.instance;
  late String ip;
  late int tcpPort;
  late int udpPort;
  late String udpTag;
  late ServerSocket serverSocket;
  Set<ClientData> clients = <ClientData>{};
  ClientData serverClient = ClientData.minimal();
  late GameData gameData;
  List<int> turnPattern = [];
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
    if (clients.length == 1) {
      list.add(serverClient.id);
      return list;
    }
    for (ClientData client in clients) {
      if (client.isReadyToPlay) {
        list.add(client.id);
      }
    }
    return list;
  }

  List<int> updateGameClickedPattern(int clicked) {
    gameData.gameClickedPattern.add(clicked);
    return gameData.gameClickedPattern;
  }

  List<int> getWonList() {
    List<int> list = List.empty();
    for (ClientData client in clients) {
      if (client.hasWon) {
        list.add(client.id);
      }
    }
    return list;
  }

  void restart(BuildContext context) {
    dispose();
    start(context);
  }

  Future<void> dispose() async {
    serverStarted = false;
    try {
      try {
        becon.cancel();
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
        await serverSocket.close();
      } catch (_) {}
      turnPattern.clear();
      serverClient = ClientData.minimal();
      gameData.clear();
      gameData.gameStarted = false;
      gameData.notifyUI();
    } catch (_) {}
  }

  int getNextTurn() {
    if (turnPattern.isEmpty) {
      gameData.turnId = gameData.serverId;
      return gameData.serverId;
    }
    int index = turnPattern.indexOf(gameData.turnId);
    if (index < 0) return gameData.serverId;
    if (index == (turnPattern.length - 1)) {
      gameData.turnId = turnPattern.first;
      return gameData.turnId;
    }
    gameData.turnId = turnPattern.elementAt(++index);
    return gameData.turnId;
  }

  List<int> makeTurnPattern() {
    List<int> list = [];
    for (ClientData client in clients) {
      list.add(client.id);
    }
    list.shuffle(Random());
    turnPattern = list;
    return list;
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

  List<int> generatePattern(int id) {
    List<int> pattern = List.generate(25, (i) => i + 1);
    for (int i = 0; i < id; i++) {
      pattern.shuffle(Random());
    }
    return pattern;
  }

  BuildContext? _context;

  Future<void> start(BuildContext context) async {
    _context = context;
    if (serverStarted) {
      stopCommunication();
    }
    try {
      await _start();
    } catch (e) {
      gameData.connectionStatus.setStatus(
        Status.error,
        message: "Server crashed",
      );
      gameData.notifyUI();
    }
  }

  Future<void> _start() async {
    availableId = [
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24,
      25,
      26,
      27,
    ];
    serverStarted = true;
    UserDatabase userDatabase = UserDatabase.instance;
    ip = await net.getLocalIPv4();
    tcpPort = net.tcpPort;
    udpPort = net.udpPort;
    udpTag = net.udpTag;
    String? name = await userDatabase.getUserName();
    serverClient.name = name ?? "HOST";
    int id = availableId.elementAt(Random().nextInt(availableId.length - 1));
    serverClient.id = id;
    serverClient.isReadyToPlay = true;
    availableId.remove(id);
    clients.add(serverClient);
    if (!turnPattern.contains(id)) {
      turnPattern.add(id);
    }
    gameData.playersWithId[id] = serverClient.name;
    gameData.serverId = serverClient.id;
    gameData.setId(serverClient.id);
    gameData.readyPlayers.add(id);
    gameData.setName(name);
    gameData.turnId = id;
    gameData.myPattern = generatePattern(id);
    print(gameData.myPattern);
    gameData.notifyUI();
    await UDPBroadCaster(ip, tcpPort, udpTag, udpPort);
    await startTCP(tcpPort);
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
    becon = Timer.periodic(const Duration(seconds: 1), (_) {
      udpSocket.send(
        utf8.encode(msg),
        InternetAddress('255.255.255.255'),
        udpPort,
      );
    });
  }

  void notifyUiForTheConnection() {
    if (clients.length > 1) {
      gameData.connectionStatus.setStatus(
        Status.connected,
        message: "Connected",
      );
      gameData.notifyUI();
    } else if (clients.length == 1) {
      if (gameData.gameStarted) {
        gameData.gameStarted = false;
        gameData.goBackToLobby = true;
      }
      gameData.connectionStatus.setStatus(
        Status.disconnected,
        message: "Disconnected",
      );
      gameData.notifyUI();
    }
  }

  Future<void> startTCP(int tcpPort) async {
    serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, tcpPort);
    serverSocket.listen(_handleNewClient);
  }

  void snackBar(String message) {
    if (_context == null) return;
    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Text(
          "$message",
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
        width: 200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(15),
        ),
        duration: Duration(milliseconds: 700),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleNewClient(Socket clientSocket) async {
    if (clients.length > 7) {
      return;
    }
    int id = availableId.elementAt(Random().nextInt(availableId.length - 1));
    availableId.remove(id);
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
    notifyUiForTheConnection();
    client.subscription = clientSocket.lines.listen(
      (line) {
        try {
          json = jsonDecode(line);
          clientSendDto = ClientSendDto.fromJson(json);
          id = clientSendDto.id ?? id;
          client.name = clientSendDto.name;
          if (!gameData.playersWithId.containsKey(id)) {
            gameData.playersWithId[id] = client.name;
          }
          client.hasWon = clientSendDto.isWon;
          if (client.hasWon) {
            gameData.addWonPlayer(client.id);
            gameData.wonList = getWonList();
            gameData.wonId = gameData.wonList.first;
            gameData.goToWinPage = true;
            getTurnIdONTurnRemove(client.id);
          }
          client.isReadyToPlay = clientSendDto.isReady;
          client.gotPattern = clientSendDto.gotPattern;
          client.pattern = clientGamePattern;
          client.noOfPatternMatched = clientSendDto.noOfPatternMatched;
          gameData.updateGameClickedPattern(
            clientSendDto.recentlyClicked ?? -11,
          );
          gameData.recentlyClicked = clientSendDto.recentlyClicked ?? -11;
          if (clientSendDto.messageType == MessageType.clicked) {
            getNextTurn();
          }
          gameData.calculateWon();
          if (gameData.wonList.contains(serverClient.id)) {
            serverClient.hasWon = true;
          }
          snackBar("Communicated with Client");
          gameData.notifyUI();
          sendPatternToAllTheClientWhoHaventGot();
          _sendGameDataToAllTheClients();
        } catch (e, st) {
          print('Error handling client message: $e');
          print(st);
          print('Raw client line: $line');
          // Remove client if message processing fails to keep state consistent
          _handleTheRemovalOfTheClient(clientSocket, id);
        }
      },
      onError: (error) {
        _handleTheRemovalOfTheClient(clientSocket, id);
      },
      onDone: () {
        _handleTheRemovalOfTheClient(clientSocket, id);
      },
      cancelOnError: true,
    );
    net.cancelOn(client.subscription!, () {
      _handleTheRemovalOfTheClient(clientSocket, id);
    });
  }

  void _handleTheRemovalOfTheClient(Socket clientsocket, int id) {
    notifyUiForTheConnection();
    clients.removeWhere((client) => client.clientSocket == clientsocket);
    gameData.playersWithId = getClientsWithId();
    gameData.readyPlayers = getReadyPlayers();
    gameData.wonList = getWonList();
    clientsocket.destroy();
    getTurnIdONTurnRemove(id);
    _sendGameDataToAllTheClients();
    if (getClientsWithId().length == 1) {
      gameData.goBackToLobby = true;
      gameData.gameStarted = false;
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

  void sendDataFromServerPlayerToOtherPlayers(ClientSendDto CSDTO) {
    serverClient.hasWon = CSDTO.isWon;
    if (serverClient.hasWon) {
      gameData.addWonPlayer(serverClient.id);
      getTurnIdONTurnRemove(serverClient.id);
    }
    serverClient.isReadyToPlay = CSDTO.isReady;
    gameData.gameStarted = CSDTO.isReady;
    serverClient.gotPattern = CSDTO.gotPattern;
    serverClient.noOfPatternMatched = CSDTO.noOfPatternMatched;
    gameData.updateGameClickedPattern(CSDTO.recentlyClicked!);
    getNextTurn();
    if (gameData.gameStarted) {
      startGame();
    }
    sendPatternToAllTheClientWhoHaventGot();
    _sendGameDataToAllTheClients();
  }

  void sendPatternToAllTheClientWhoHaventGot() {
    // if (clients.length == 1) return;
    // if (!gameData.gameStarted) {
    //   ServerSendDto serverSendDto = ServerSendDto(
    //     playersWithId: getClientsWithId(),
    //     readyPlayers: getReadyPlayers(),
    //     gameStarted: gameData.gameStarted,
    //     clientIdWithPattern: PatternWithId(id: -1, pattern: List.empty()),
    //     messageType: MessageType.automatic,
    //   );
    //   serverSendDto.messageType = MessageType.automatic;
    //   serverSendDto.turnId = gameData.turnId;
    //   serverSendDto.wonList = List.empty();
    //   List<ClientData> clientsCopy = clients.toList();
    //   List<int> pattern;
    //   for (int i = 0; i < clientsCopy.length; i++) {
    //     ClientData client = clients.elementAt(i);
    //     if (client.id == serverClient.id) continue;
    //     if (!client.gotPattern) {
    //       try {
    //         pattern = generatePattern(client.id);
    //         client.pattern = pattern;
    //         serverSendDto.clientIdWithPattern = PatternWithId(
    //           id: client.id,
    //           pattern: client.pattern,
    //         );
    //         serverSendDto.gameClickedPattern = gameData.gameClickedPattern;
    //         serverSendDto.wonList = getWonList();
    //         serverSendDto.recentlyClicked = gameData.recentlyClicked;
    //         Map<String, dynamic> messageJson = serverSendDto.toJson();
    //         sendMessageToClient(client, messageJson);
    //       } catch (e) {
    //         gameData
    //           ..connectionStatus.setStatus(
    //             Status.disconnected,
    //             message: "Disconnected",
    //           )
    //           ..notifyUI();

    //         _handleTheRemovalOfTheClient(client.clientSocket, client.id);
    //       }
    //     }
    //   }
    // }
  }

  void mofidyContext(BuildContext con) {
    _context = con;
  }

  void startGame() {
    gameData.gameStarted = true;
    makeTurnPattern();
    gameData.turnId = turnPattern.first;
    _sendGameDataToAllTheClients();
    gameData.connectionStatus.setStatus(
      Status.idle,
      message: "Inside the game",
    );
    gameData.notifyUI();
  }

  void removeClient(int id) {
    clients.removeWhere((client) => client.id == id);
  }

  void _sendGameDataToAllTheClients() {
  //   ServerSendDto serverSendDto = ServerSendDto(
  //     playersWithId: getClientsWithId(),
  //     readyPlayers: getReadyPlayers(),
  //     gameStarted: gameData.gameStarted,
  //     gameClickedPattern: gameData.gameClickedPattern,
  //     wonList: getWonList(),
  //     turnId: gameData.turnId,
  //     clientIdWithPattern: PatternWithId(id: -4, pattern: List.empty()),
  //     messageType: MessageType.automatic,
  //   );
  //   serverSendDto.clientIdWithPattern = PatternWithId(
  //     id: -4,
  //     pattern: List.empty(),
  //   );
  //   gameData.readyPlayers = getReadyPlayers();
  //   gameData.wonList = getWonList();
  //   serverSendDto.recentlyClicked = gameData.recentlyClicked;
  //   Map<String, dynamic> messageJson = serverSendDto.toJson();
  //   sendMessage(messageJson);
  // }

  // void sendGameDataToAllTheClients() {
  //   gameData.turnId = getNextTurn();
  //   ServerSendDto serverSendDto = ServerSendDto(
  //     playersWithId: gameData.playersWithId,
  //     readyPlayers: gameData.readyPlayers,
  //     gameStarted: gameData.gameStarted,
  //     gameClickedPattern: gameData.gameClickedPattern,
  //     wonList: getWonList(),
  //     turnId: gameData.turnId,
  //     messageType: MessageType.clicked,
  //     clientIdWithPattern: PatternWithId(id: -0, pattern: List.empty()),
  //   );
  //   Map<String, dynamic> messageJson = serverSendDto.toJson();
  //   gameData.notifyUI();
  //   sendMessage(messageJson);
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

  void sendMessage(Map<String, dynamic> messageJson) {
    String msg = jsonEncode(messageJson);
    int length = clients.length;
    for (int i = 0; i < length; i++) {
      ClientData client = clients.elementAt(i);
      if (client.id == serverClient.id) continue;
      try {
        client.clientSocket.write(
          '$msg\n',
        ); // client.clientSocket.add(utf8.encode('$msg\n'));
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
    gameData.savePattern();

    stopScanningDevices();
    for (ClientData client in clients) {
      client.clientSocket.destroy();
      client.subscription!.cancel();
    }
    serverSocket.close();
    clients.clear();
    serverStarted = false;
    gameData.clear();
    gameData.notifyUI();
  }
}
