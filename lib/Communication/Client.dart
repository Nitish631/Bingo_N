import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bingo_n/Communication/NetworkData.dart';
import 'package:bingo_n/DTOs/ClientSendDto.dart';
import 'package:bingo_n/DTOs/ServerSendDto.dart';
import 'package:bingo_n/GameData/GameData.dart';
import 'package:bingo_n/DTOs/navData.dart';
import 'package:bingo_n/Extensions/TcpExtension.dart';
import 'package:bingo_n/GameData/ConnectionStatus.dart';
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
  late Gamedata gameData;
  String? clientName;
  // bool _isSocketOpen = false;
  Client._privateConstructor();
  static final Client instance = Client._privateConstructor();
  BuildContext? context;
  void start(BuildContext context) async {
    try {
      gameData = Gamedata.instance;
      gameData.connectionStatus.setStatus(Status.connecting,message: "Connecting");
      gameData.notifyUI();
      dispose();
      this.context = context;
      gameData.isServer = false;
      gameData.currentPage = Navdata.lobby;
      gameData.notifyUI();
      await _start();
    } catch (e) {
      snackBar("Error starting client. Please try again.");
      print("ERROR IN CLIENT . CRASHED : $e");
      _handleTheDisconnectionWithSerrver();
    }
  }

  void snackBar(String message) {
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(milliseconds: 500)),
    );
  }

  void _handleTheDisconnectionWithSerrver() {
    if (gameData.currentPage == Navdata.gamingPage) {
      gameData.currentPage = Navdata.rolePage;
    }
    gameData.showReconnectButton = true;
    gameData.connectionStatus.setStatus(
      Status.disconnected,
      message: "Disconnected",
    );
    gameData.notifyUI();
    dispose();
  }

  void updateGameClickedPattern(int num) {
    if (num > 0) {
      if (gameData.turnId == gameData.myId) {
        if (!gameData.gameClickedPattern.contains(num)) {
          gameData.gameClickedPattern.add(num);
        }
        ClientSendDto clientSendDto = ClientSendDto(
          name: gameData.name ?? "",
          isWon: gameData.isWon(),
          isReady: gameData.isReady,
          id: gameData.myId,
          gotPattern: gameData.myPattern.isNotEmpty,
          noOfPatternMatched: gameData.indexesOfWonPatternMatched.length,
          messageType: MessageType.clicked,
          recentlyClicked: num,
        );
        if (gameData.isWon()) {
          gameData.wonId = gameData.myId;
          gameData.currentPage = Navdata.wonPage;
          // gameData.notifyUI();
        }
        snackBar("Won is ${clientSendDto.isWon ? "" : "not"} send");
        sendMessageToServer(clientSendDto);
      }
    }
  }

  void _handleClient(Map<String, dynamic> json) {
    ServerSendDto serverSendDto = ServerSendDto.fromJson(json);
    // snackBar("Update from server: ${serverSendDto.readyPlayers.toString()}");
    gameData
      ..playersWithId = serverSendDto.playersWithId
      ..currentPage = serverSendDto.currentPage
      ..readyPlayers = serverSendDto.readyPlayers
      ..gameClickedPattern = serverSendDto.gameClickedPattern!
      ..wonId = serverSendDto.wonId
      ..turnId = serverSendDto.turnId!
      ..setMyPattern(serverSendDto.clientIdWithPattern)
      ..recentlyClicked = serverSendDto.recentlyClicked
      ..calculateWon()
      ..notifyUI();
    if (serverSendDto.messageType == MessageType.clicked) {
      _sendDataAutomatically();
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

  Future<void> _discoverAndConnect() async {
    try {
      gameData.connectionStatus.setStatus(
        Status.discovering,
        message: "Scanning for host",
      );
      gameData.notifyUI();
      (String, int)? host = await _discoverHost(timeout: Duration(seconds: 10));
      if (host == null) {
        if (gameData.currentPage == Navdata.gamingPage) {
          gameData.currentPage = Navdata.rolePage;
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
        // snackBar("TCP CRASHED");
      }
      _send(clientSendDto);
      gameData.connectionStatus.setStatus(
        Status.connected,
        message: "Connected",
      );
      // snackBar("Connected");
      gameData.notifyUI();
      tcpSub = tcpSocket!.lines.listen(
        (line) {
          Map<String, dynamic> json = jsonDecode(line);
          if (json.isNotEmpty) {
            _handleClient(json);
          }
        },
        onError: (e) {
          _handleTheDisconnectionWithSerrver();
        },
        onDone: () {
          _handleTheDisconnectionWithSerrver();
        },
      );
    } catch (e) {
      _handleTheDisconnectionWithSerrver();
    }
  }

  void modifyContext(BuildContext context) {
    this.context = context;
  }

  void _sendDataAutomatically() {
    if (gameData.turnId == gameData.myId) {
      ClientSendDto clientSendDto = ClientSendDto(
        name: gameData.name ?? "",
        isWon: gameData.isWon(),
        isReady: gameData.isReady,
        id: gameData.myId,
        gotPattern: gameData.myPattern.isNotEmpty,
        noOfPatternMatched: gameData.indexesOfWonPatternMatched.length,
        messageType: MessageType.automatic,
        recentlyClicked: -11,
      );
      snackBar("Won is ${clientSendDto.isWon ? "" : "not"} send");
      sendMessageToServer(clientSendDto);
    }
  }

  void notifyReadyToAll(bool ready) {
    ClientSendDto clientSendDto = ClientSendDto(
      name: gameData.name ?? "",
      isWon: false,
      isReady: ready,
      id: gameData.myId,
      gotPattern: gameData.myPattern.isNotEmpty,
      noOfPatternMatched: 0,
      messageType: MessageType.clicked,
      recentlyClicked: -11,
    );
    sendMessageToServer(clientSendDto);
  }

  _send(ClientSendDto clientSendDto) {
    Map<String, dynamic> msgJson = clientSendDto.toJson();
    String msg = jsonEncode(msgJson);
    try {
      if (tcpSocket == null) {
        _handleTheDisconnectionWithSerrver();
        return;
      }
      tcpSocket!.write('$msg\n');
    } catch (e) {
      if (gameData.currentPage == Navdata.gamingPage) {
        gameData.currentPage = Navdata.rolePage;
      }
      gameData.showReconnectButton = true;
      gameData.connectionStatus.setStatus(
        Status.disconnected,
        message: "Connection loss!",
      );
      gameData.notifyUI();
      _handleTheDisconnectionWithSerrver();
    }
  }

  void sendMessageToServer(ClientSendDto clientSendDto) {
    _send(clientSendDto);
  }

  void dispose() {
    gameData = Gamedata.instance;
    serverIPAddress = "";
    try {
      tcpSocket?.close();
    } catch (_) {}
    try {
      udpSocket.close();
    } catch (_) {}
    try {
      clientSendDto.clear();
    } catch (_) {}
    try {
      tcpSub?.cancel();
    } catch (_) {}
    try {
      serverSendDto.clear();
    } catch (_) {}
    gameData.clear();
    gameData.notifyUI();
  }

  Future<void> _start() async {
    udpPort = net.udpPort;
    tcpPort = net.tcpPort;
    udpTag = net.udpTag;
    userDatabase = UserDatabase.instance;
    clientName = await userDatabase.getUserName();
    clientSendDto.gotPattern = false;
    clientSendDto.isReady = false;
    clientSendDto.isWon = false;
    clientSendDto.name = clientName!;
    await _discoverAndConnect();
  }
}
