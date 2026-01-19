import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bingo_n/Communication/NetworkData.dart';
import 'package:bingo_n/DTOs/ClientSendDto.dart';
import 'package:bingo_n/DTOs/ServerSendDto.dart';
import 'package:bingo_n/Extensions/TcpExtension.dart';
import 'package:bingo_n/GameData/ConnectionStatus.dart';
import 'package:bingo_n/GameData/GameData.dart';
import 'package:bingo_n/database/userInfo.dart';

class Client {
  late String serverIPAddress;
  late RawDatagramSocket udpSocket;
  late Socket tcpSocket;
  NetworkData net = NetworkData.instance;
  late int udpPort;
  late int tcpPort;
  late String udpTag;
  late ClientSendDto clientSendDto;
  late UserDatabase userDatabase;
  late StreamSubscription tcpSub;
  late ServerSendDto serverSendDto;
  late GameData gameData;
  String? clientName;

  void start() async {
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
    _discoverAndConnect();
  }

  void restartConnection() {
    dispose();
    start();
  }

  void dispose() {
    _handleTheDisconnectionWithServer();
  }

  void _handleTheDisconnectionWithServer() {
    if (gameData.myPattern != []) {
      userDatabase.updatePattern(gameData.myPattern);
    }
    gameData.clear();
    tcpSocket.close();
    serverIPAddress = "";
    udpSocket.close();
    clientSendDto.clear();
    tcpSub.cancel();
    serverSendDto.clear();
  }

  void _send(ClientSendDto csd) {
    Map<String, dynamic> msgJson = csd.toJson();
    String msg = jsonEncode(msgJson);
    try {
      tcpSocket.write('$msg\n'); // tcpSocket.add(utf8.encode('$msg\n'));
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

  int? getMyId() {
    return serverSendDto.playersWithId.entries
                .firstWhere(
                  (entry) => entry.value == clientName,
                  orElse: () => const MapEntry(-1, ''),
                )
                .key ==
            -1
        ? null
        : serverSendDto.playersWithId.entries
              .firstWhere((e) => e.value == clientName)
              .key;
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
      tcpSocket = await Socket.connect(
        host.$1,
        host.$2,
        timeout: const Duration(seconds: 5),
      );
      _send(clientSendDto);
      gameData.connectionStatus.setStatus(
        Status.connected,
        message: "Connected",
      );
      gameData.notifyUI();
      tcpSub = tcpSocket.lines.listen(
        (line) {
          Map<String, dynamic> msgJson = jsonDecode(line);
          if (msgJson.isNotEmpty) {
            serverSendDto = ServerSendDto.fromJson(msgJson);
            gameData.setPlayersWithId(serverSendDto.playersWithId);
            gameData.gameStarted = serverSendDto.gameStarted;
            gameData.readyPlayers = serverSendDto.readyPlayers;
            gameData.gameClickedPattern = serverSendDto.gamePattern!;
            gameData.wonList = serverSendDto.wonList!;
            gameData.turnId = serverSendDto.turnId!;
            gameData.myPattern = serverSendDto.clientIdWithPattern!.pattern;
            gameData.setId(getMyId());
            gameData.notifyUI();
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
    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, udpPort);
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
}
