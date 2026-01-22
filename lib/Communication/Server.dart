import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bingo_n/Communication/NetworkData.dart';
import 'package:bingo_n/DTOs/ClientData.dart';
import 'package:bingo_n/DTOs/ClientSendDto.dart';
import 'package:bingo_n/DTOs/PatternWithId.dart';
import 'package:bingo_n/DTOs/ServerSendDto.dart';
import 'package:bingo_n/Extensions/TcpExtension.dart';
import 'package:bingo_n/GameData/ConnectionStatus.dart';
import 'package:bingo_n/GameData/GameData.dart';
import 'package:bingo_n/database/userInfo.dart';

class Server {
  static Server instance=Server._init();
  Server._init();
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
  ClientData serverClient=ClientData.minimal(id: 0);
  GameData gameData=GameData.instance;
  late List<int> turnPattern;
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
    gameData.gameClickedPattern.add(clicked);
    return gameData.gameClickedPattern;
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
    int index = turnPattern.indexOf(gameData.turnId);
    if (index == (turnPattern.length - 1)) {
      gameData.turnId = turnPattern.elementAt(0);
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
    turnPattern = list;
    return list;
  }

  int getTurnIdONTurnRemove(int id) {
    int index = turnPattern.indexOf(id);
    int length = turnPattern.length;
    turnPattern.remove(id);
    if (index == (length - 1)) {
      if(turnPattern.length==0){
        gameData.turnId=-1;
        return gameData.turnId;
      }
      gameData.turnId = turnPattern.elementAt(0);
    } else {
      gameData.turnId = turnPattern.elementAt(index);
    }
    return gameData.turnId;
  }

  List<int> generatePattern(int id) {
    return List.empty();
  }

  Future<void> start() async {
    UserDatabase userDatabase=UserDatabase.instance;
    ip = await net.getLocalIPv4();
    tcpPort = net.tcpPort;
    udpPort = net.udpPort;
    udpTag = net.udpTag;
    String? name= await userDatabase.getUserName();
    serverClient.name=name??"HOST";
    clients.add(serverClient);
    gameData.setName(name);
    gameData.setId(serverClient.id);
    gameData.myPattern=await userDatabase.getStoredPattern();
    gameData.notifyUI();
    await startTCP(tcpPort);
    await UDPBroadCaster(ip, tcpPort, udpTag, udpPort);
  }

  Future<void> UDPBroadCaster(
    String ip,
    int tcpPort,
    String udpTag,
    int udpPort,
  ) async {
    gameData.connectionStatus.setStatus(Status.discovering,message: "Scanning Players.");
    gameData.notifyUI();
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
        if(client.hasWon){
          gameData.addWonPlayer(client.id);
          getTurnIdONTurnRemove(client.id);
        }
        client.isReadyToPlay = clientSendDto.isReady;
        client.gotPattern = clientSendDto.gotPattern;
        client.pattern = clientGamePattern;
        client.noOfPatternMatched=clientSendDto.noOfPatternMatched;
        gameData.updateGameClickedPattern(clientSendDto.recentlyClicked!);
        getNextTurn();
        gameData.calculateWon();
        if(gameData.wonList.contains(serverClient.id)){
          serverClient.hasWon=true;
        }
        sendPatternToAllTheClientWhoHaventGot();
        _sendGameDataToAllTheClients();
        gameData.notifyUI();
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
    getTurnIdONTurnRemove(id);
    _sendGameDataToAllTheClients();
    gameData.notifyUI();
  }
  void sendDataFromServerPlayerToOtherPlayers(ClientSendDto CSDTO){
        serverClient.hasWon = CSDTO.isWon;
        if(serverClient.hasWon){
          gameData.addWonPlayer(serverClient.id);
          getTurnIdONTurnRemove(serverClient.id);
        }
        serverClient.isReadyToPlay = CSDTO.isReady;
        gameData.gameStarted=CSDTO.isReady;
        serverClient.gotPattern = CSDTO.gotPattern;
        serverClient.noOfPatternMatched=CSDTO.noOfPatternMatched;
        gameData.updateGameClickedPattern(CSDTO.recentlyClicked!);
        getNextTurn();
        if(gameData.gameStarted){
          startGame();
        }
        sendPatternToAllTheClientWhoHaventGot();
        _sendGameDataToAllTheClients();
  }
  void sendPatternToAllTheClientWhoHaventGot() {
    if (!gameData.gameStarted) {
      ServerSendDto serverSendDto = ServerSendDto(
        playersWithId: getClientsWithId(),
        readyPlayers: getReadyPlayers(),
        gameStarted:gameData.gameStarted,
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
          serverSendDto.gameClickedPattern = gameData.gameClickedPattern;
          serverSendDto.wonList = getWonList();
          Map<String, dynamic> messageJson = serverSendDto.toJson();
          sendMessage(messageJson);
        }
      }
    }
  }
  void startGame(){
    gameData.gameStarted=true;
    gameData.connectionStatus.setStatus(Status.idle,message: "Inside the game");
    gameData.notifyUI();
  }
  void removeClient(int id){
    clients.removeWhere((client)=>client.id==id);
  }

  void _sendGameDataToAllTheClients() {
    ServerSendDto serverSendDto = ServerSendDto(
      playersWithId: getClientsWithId(),
      readyPlayers: getReadyPlayers(),
      gameStarted:gameData.gameStarted,
      gameClickedPattern: gameData.gameClickedPattern,
      wonList: getWonList(),
      turnId: gameData.turnId,
    );
    gameData.setPlayersWithId(getClientsWithId());
    gameData.readyPlayers=getReadyPlayers();
    gameData.wonList=getWonList();

    Map<String, dynamic> messageJson = serverSendDto.toJson();
    sendMessage(messageJson);
  }
  void sendGameDataToAllTheClients(){
    ServerSendDto serverSendDto = ServerSendDto(
      playersWithId: gameData.playersWithId,
      readyPlayers: gameData.readyPlayers,
      gameStarted:gameData.gameStarted,
      gameClickedPattern: gameData.gameClickedPattern,
      wonList: gameData.wonList,
      turnId: gameData.turnId,
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
    UserDatabase.instance.updatePattern(generatePattern(140));
    stopScanningDevices();
    for (ClientData client in clients) {
      client.clientSocket.destroy();
    }
    sub.cancel();
    serverSocket.close();
    clients.clear();
    GameData.instance.clear();
  }
  void handleTheServerPlayer(){
    
  }
}
