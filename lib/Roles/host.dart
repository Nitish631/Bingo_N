import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bingo_n/DTOs/stateService.dart';
import 'package:bingo_n/boundedSet.dart';
import 'package:bingo_n/Communication/NetworkData.dart';
import 'package:bingo_n/screen/GamingPage.dart';
import 'package:flutter/material.dart';
import 'package:bingo_n/main.dart';
import 'package:bingo_n/GameState/state.dart';
import 'package:google_fonts/google_fonts.dart';

final net = NetworkData.instance;
final service = Stateservice.instance;
Duration beconInterval = Duration(seconds: 1);
bool isAllPlayerReady() {
  if (gmst.clientNames.length == gmst.clientsAlloweded?.length) return true;
  return false;
}

extension SocketLines on Socket {
  Stream<String> get lines => cast<List<int>>()
      .transform(const Utf8Decoder())
      .transform(const LineSplitter());
}

class HostPage extends StatefulWidget {
  const HostPage({super.key});
  static HostPage instance = HostPage._init();
  HostPage._init();
  @override
  State<HostPage> createState() => _HostState();
}

class _HostState extends State<HostPage> {
  ServerSocket? server;
  final BoundedSet clients = BoundedSet.instance;
  RawDatagramSocket? udp;
  Timer? becon;
  String hostIP = '....';
  Map<String, dynamic>? userData;
  List<List<int>>? patterns;
  bool isListGeneratedAndUpdated = false;
  @override
  void initState() {
    super.initState();
    _initHost();
  }

  Future<void> _initHost() async {
    userData = gmst.userData;
    pattern = userData?['pattern'];
    myName = userData?['name'];
    patterns = await generatePattern(pattern);
    await _startHost();
  }

  Future<List<List<int>>> generatePattern(List<int> pattern) async {
    List<List<int>> tempPatterns = [];
    tempPatterns.add(pattern);
    List<int> tempPattern = [];
    for (int i = 1; i <= 6; i++) {
      tempPattern = pattern;
      int counter = 1;
      for (final i in pattern) {
        tempPattern[i] = counter;
        counter++;
      }
      pattern = tempPattern;
      tempPatterns.add(pattern);
    }
    isListGeneratedAndUpdated = await gmst.updatePattern(pattern);
    return tempPatterns;
  }

  Future<void> _startHost() async {
    hostIP = await net.getLocalIPv4();
    server = await ServerSocket.bind(InternetAddress.anyIPv4, net.tcpPort);
    server!.listen(_handleNewClient);
    udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    udp!.broadcastEnabled = true;
    becon = Timer.periodic(beconInterval, (time) {
      final msg = '${net.udpTag}:$hostIP:${net.tcpPort}';
      udp!.send(
        utf8.encode(msg),
        InternetAddress('255.255.255.255'),
        net.udpPort,
      );
    });
    setState(() {});
  }

  void _handleNewClient(Socket client) {
    clients.add(client);
    _broadcastGameState(true, 55, false);
    final sub = client.lines.listen(
      (line) {
        setState(() {
          final dataMap = service.deserializeState(line);
          gotRecentSelected = dataMap['recentSelected'];
          if (dataMap.containsKey("Name"))
            gmst.clientNames.add(dataMap['Name']);
          if (dataMap.containsKey('clientAlloweded'))
            gmst.clientsAlloweded?.add(true);
        });
      },
      onError: (error) {
        clients.remove(client);
        client.destroy();
      },
      onDone: () {
        clients.remove(client);
        client.destroy();
      },
      cancelOnError: true,
    );
    net.cancelOn(sub, () {
      clients.remove(client);
      client.destroy();
    });
  }

  void _broadcastGameState(bool isFirst, int recentSelected, bool isWonGame) {
    int counter = 1;
    String msg;
    for (final c in clients.set.toList()) {
      if (isFirst) {
        msg = service.serializeState(
          recentSelected: recentSelected,
          turn: false,
          Name: userData?['name'],
          clientPattern: patterns?[counter],
        );
      } else {
        final isTurn = service.turn[counter];
        msg = service.serializeState(
          turn: isTurn,
          recentSelected: recentSelected,
        );
      }
      counter++;
      try {
        c.write('$msg\n');
      } catch (error) {
        clients.remove(c);
        c.destroy();
      }
    }
  }

  @override
  void dispose() {
    becon?.cancel();
    udp?.close();
    // for (final c in clients.set.toList()) {
    //   c.destroy();
    // }
    // server?.close();
    super.dispose();
  }

  void stopScanningDevices() {
    becon?.cancel();
    udp?.close();
  }

  @override
  Widget build(BuildContext context) {
    return (clients.isEmpty() && !isListGeneratedAndUpdated)
        ? Scaffold(
            body: Container(
              height: double.infinity,
              width: double.infinity,
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: Container(
              height: double.infinity,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 16),
                    child: Column(
                      children: List.generate(gmst.clientNames.length, (index) {
                        return Container(
                          height: 50,
                          width: 150,
                          child: Text(
                            "${gmst.clientNames[index]}",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Color.fromRGBO(54, 27, 10, 1),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (isAllPlayerReady()) {
                        final msg = jsonEncode({"HostStartedGame": true});
                        for (Socket c in clients.set) {
                          c.write(msg);
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Gamingpage()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(255, 98, 0, 1),
                    ),
                    child: Text(
                      "START GAME",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Color.fromRGBO(255, 255, 0, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
