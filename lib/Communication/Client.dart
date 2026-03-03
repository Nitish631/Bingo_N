import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bingo_n/Communication/NetworkData.dart';
import 'package:bingo_n/DTOs/ClientSendDto.dart';
import 'package:bingo_n/DTOs/ServerSendDto.dart';
import 'package:bingo_n/Extensions/TcpExtension.dart';
import 'package:bingo_n/GameData/ConnectionStatus.dart';
import 'package:bingo_n/GameData/GameData.dart';
import 'package:bingo_n/GameData/MessageType.dart';
import 'package:bingo_n/database/userInfo.dart';
import 'package:flutter/material.dart';

class Client {
  late String serverIPAddress;
  late RawDatagramSocket udpSocket;
  Socket? tcpSocket;
  NetworkData net = NetworkData.instance;
  late int udpPort;
  late int tcpPort;
  late String udpTag;
  ClientSendDto clientSendDto = ClientSendDto.min(
    gotPattern: false,
    isReady: false,
    isWon: false,
  );
  late UserDatabase userDatabase;
  StreamSubscription? tcpSub;
  late ServerSendDto serverSendDto;
  late GameData gameData;
  String? clientName;

  static Client instance = Client._init();
  Client._init();
  BuildContext? context;
  Future<void> start(BuildContext context) async {
    this.context = context;
    try {
      await _start();
      gameData.attachClient(this);
    } catch (e) {
      gameData.connectionStatus.setStatus(
        Status.error,
        message: "Client crashed",
      );
      gameData.notifyUI();
    }
  }

  // void snackBar(String message) {
  //   ScaffoldMessenger.of(context!).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         "$message",
  //         style: TextStyle(fontSize: 12, color: Colors.white),
  //       ),
  //       width: 250,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadiusGeometry.circular(15),
  //       ),
  //       duration: Duration(milliseconds: 700),
  //       behavior: SnackBarBehavior.floating,
  //     ),
  //   );
  // }

  Future<void> _start() async {
    udpPort = net.udpPort;
    tcpPort = net.tcpPort;
    udpTag = net.udpTag;
    userDatabase = UserDatabase.instance;
    gameData = GameData.instance;
    gameData.clear();
    clientName = await userDatabase.getUserName();
    clientSendDto.gotPattern = false;
    clientSendDto.isReady = false;
    clientSendDto.isWon = false;
    clientSendDto.name = clientName!;
    await _discoverAndConnect();
  }

  void restartConnection(BuildContext context) {
    dispose();
    start(context);
  }

  void dispose() {
    _handleTheDisconnectionWithServer();
  }

  void _handleTheDisconnectionWithServer() {
    if (gameData.myPattern != []) {
      userDatabase.updatePattern(gameData.myPattern);
    }
    gameData.connectionStatus.setStatus(
      Status.error,
      message: "Client crashed",
    );
    gameData.notifyUI();
    gameData.clear();
    tcpSocket?.close();
    serverIPAddress = "";
    udpSocket.close();
    clientSendDto.clear();
    tcpSub?.cancel();
    serverSendDto.clear();
  }

  void _send(ClientSendDto csd) {
    Map<String, dynamic> msgJson = csd.toJson();
    String msg = jsonEncode(msgJson);
    try {
      tcpSocket!.write('$msg\n'); // tcpSocket!.add(utf8.encode('$msg\n'));
    } catch (e) {
      if (gameData.gameStarted) {
        gameData.goBackToLobby = true;
      }
      gameData.showReconnectButton = true;
      gameData.connectionStatus.setStatus(
        Status.disconnected,
        message: "Connection loss!",
      );
      gameData.notifyUI();
      _handleTheDisconnectionWithServer();
    }
  }

  // int? getMyId() {
  //   return serverSendDto.playersWithId.entries
  //               .firstWhere(
  //                 (entry) => entry.value == clientName,
  //                 orElse: () => const MapEntry(-1, ''),
  //               )
  //               .key ==
  //           -1
  //       ? null
  //       : serverSendDto.playersWithId.entries
  //             .firstWhere((e) => e.value == clientName)
  //             .key;
  // }

  Future<void> _discoverAndConnect() async {
    try {
      gameData.connectionStatus.setStatus(
        Status.discovering,
        message: "Scanning for host",
      );
      gameData.notifyUI();
      (String, int)? host = await _discoverHost(timeout: Duration(seconds: 10));
      if (host == null) {
        if (gameData.gameStarted) {
          gameData.goBackToLobby = true;
        }
        gameData.connectionStatus.setStatus(
          Status.error,
          message: "No host found",
        );
        gameData.notifyUI();
        return;
      }
      serverIPAddress = host.$1;
      gameData.connectionStatus.setStatus(
        Status.connecting,
        message: "Connecting to host",
      );
      gameData.notifyUI();
      try {
        tcpSocket = await Socket.connect(
          host.$1,
          host.$2,
          timeout: const Duration(seconds: 5),
        );
      } catch (e) {
        gameData.connectionStatus.setStatus(
          Status.error,
          message: "TCP chashed",
        );
      }
      _send(clientSendDto);
      gameData.connectionStatus.setStatus(
        Status.connected,
        message: "Connected",
      );
      gameData.notifyUI();
      tcpSub = tcpSocket!.lines.listen(
        (line) {
          Map<String, dynamic> msgJson = jsonDecode(line);
          if (msgJson.isNotEmpty) {
            serverSendDto = ServerSendDto.fromJson(msgJson);
            // snackBar("MESSAGE GOT FROM SERVER");
            gameData.setPlayersWithId(serverSendDto.playersWithId);
            gameData.gameStarted = serverSendDto.gameStarted;
            gameData.readyPlayers = serverSendDto.readyPlayers;
            gameData.gameClickedPattern = serverSendDto.gameClickedPattern!;
            gameData.wonList = serverSendDto.wonList!;
            gameData.turnId = serverSendDto.turnId ?? -1;
            if (serverSendDto.clientIdWithPattern.id >= 0 &&
                serverSendDto.clientIdWithPattern.pattern.isNotEmpty) {
              gameData.myPattern = serverSendDto.clientIdWithPattern.pattern;
              gameData.setId(serverSendDto.clientIdWithPattern.id);
            }
            gameData.recentlyClicked = serverSendDto.recentlyClicked;
            gameData.updateGameClickedPattern(serverSendDto.recentlyClicked);
            gameData.calculateWon();
            gameData.hasWon();
            if (serverSendDto.messageType == MessageType.clicked) {
              gameData.sendDataForCommunication();
            }
            gameData.notifyUI();
            if(gameData.myPattern.isNotEmpty){
              // snackBar("GOT PATTERN AND ID ${gameData.myId}");
              // print(gameData.myPattern);
            }
            // snackBar("ONE CYCLE COMPLETED");
            // NECESSARY DO THE BELOW TASK
            //CHECK THE STATE AND SEND THE DATA TO THE SERVER
          }
        },
        onError: (e) {
          if (gameData.gameStarted) {
            gameData.goBackToLobby = true;
          }
          gameData.showReconnectButton = true;
          gameData.connectionStatus.setStatus(
            Status.disconnected,
            message: "Disconnected",
          );
          gameData.notifyUI();
          _handleTheDisconnectionWithServer();
        },
        onDone: () {
          if (gameData.gameStarted) {
            gameData.goBackToLobby = true;
          }
          gameData.showReconnectButton = true;
          gameData.connectionStatus.setStatus(
            Status.disconnected,
            message: "Disconnected",
          );
          gameData.notifyUI();
          _handleTheDisconnectionWithServer();
        },
      );
    } catch (e) {
      if (gameData.gameStarted) {
        gameData.goBackToLobby = true;
      }
      gameData.showReconnectButton = true;
      gameData.connectionStatus.setStatus(
        Status.disconnected,
        message: "Disconnected",
      );
      gameData.notifyUI();
      _handleTheDisconnectionWithServer();
    }
  }

  Future<(String, int)?> _discoverHost({required Duration timeout}) async {
    final completer = Completer<(String, int)>();
    udpSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      udpPort,
      reuseAddress: true,
    );
    udpSocket.broadcastEnabled = true;
    late Timer t;
    t = Timer(timeout, () {
      udpSocket.close();
      if (!completer.isCompleted) completer.complete(null);
    });
    udpSocket.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = udpSocket.receive();
        if (dg == null) return;
        final msg = utf8.decode(dg.data);
        if (msg.startsWith(udpTag)) {
          final parts = msg.split('|');
          if (parts.length == 3) {
            String ip = parts[1];
            int port = int.tryParse(parts[2]) ?? tcpPort;
            t.cancel();
            udpSocket.close();
            if (!completer.isCompleted) completer.complete((ip, port));
          }
        }
      }
    });
    return completer.future;
  }

  void sendMessageToServer(ClientSendDto clientSendDto) {
    // snackBar("READY MESSAGE SENDING");
    // print("READY MESSAGE SENDING");
    _send(clientSendDto);
  }
}
