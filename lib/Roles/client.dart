import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bingo_n/GameState/state.dart';
import 'package:bingo_n/Service/stateService.dart';
import 'package:bingo_n/network/network.dart';
import 'package:bingo_n/screen/GamingPage.dart';
import 'package:flutter/material.dart';
import 'package:bingo_n/main.dart';
import 'package:google_fonts/google_fonts.dart';
void _send(bool isFirst,int recentSelected,Socket? tcp){
    final msg;
    if(isFirst){
      msg=service.serializeState(turn: false, recentSelected: recentSelected,Name: gmst.userData?['name'],);
    }else{
      msg=service.serializeState(turn: false, recentSelected: recentSelected);
    }
    tcp?.write('$msg\n');
  }
class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientState();
}
extension SocketLines on Socket{
  Stream<String> get lines=>cast<List<int>>().transform(const Utf8Decoder()).transform(const LineSplitter());
}
final net=Network.instance;
final service=Stateservice.instance;
class _ClientState extends State<ClientPage> {
  int joinPressed=0;
  String gameJoinState="JOIN GAME";
  RawDatagramSocket?udp;
  Socket? tcp;
  String status ='Discovering host....';
  StreamSubscription<String>?tcpSub;
  Map<String,dynamic>?userData;
  @override
  void initState(){
    super.initState();
    _discoverAndConnect();
  }
  Future<void>_discoverAndConnect() async{
    try{
      final host= await _discoverHost(timeout: Duration(seconds: 10));
      if(host==null){
        setState(() {
          status='NO HOST FOUND';
        });
        return;
      }
        setState(() {
          status='Connecting to host';
        });
        tcp= await Socket.connect(host.$1,host.$2,timeout: const Duration(seconds: 5));
        _send(true,55, tcp);
        tcpSub =tcp!.lines.listen((line){
          setState(() {
            final st=service.deserializeState(line);
            if(st.isNotEmpty){
              gmst.gameData=st;
              if(gmst.gameData.containsKey('HostStartedGame')) gmst.hostStartedGame=true;
              if(gmst.gameData.containsKey('Name')&& gmst.gameData.containsKey('clientPattern')){
              hostName=gmst.gameData['Name'];
              pattern=gmst.gameData['clientPattern'];
            }else{
              isMyTurn=gmst.gameData['isMyTurn'];
              gotRecentSelected=gmst.gameData['recentSelected'];
            }
            }
          });
        },onDone: () {
          setState(() {
            status='Disconnected';
          });
        },onError: (error){
          setState(() {
            status='Connection error';
          });
        }
        );
        setState(() {
          status="Connected";
        });
    }catch(error){
      setState(() {
        status='Error: $error';
      });
    }
  }
  Future<(String,int)?> _discoverHost({required Duration timeout})async{
    final completer=Completer<(String,int)?>();
    udp=await RawDatagramSocket.bind(InternetAddress.anyIPv4,net.udpPort);
    udp!.broadcastEnabled=true;
    late Timer t;
    t=Timer(timeout,(){
      udp?.close();
      if(!completer.isCompleted) completer.complete(null);
    });
    udp!.listen((event){
      if(event==RawSocketEvent.read){
        final dg=udp!.receive();
        if(dg==null)return;
        final msg=utf8.decode(dg.data);
        if(msg.startsWith(net.udpTag)){
          final parts=msg.split(':');
          if(parts.length==3){
            final ip=parts[1];
            final port=int.tryParse(parts[2])?? net.tcpPort;
            t.cancel();
            udp?.close();
            if(!completer.isCompleted) completer.complete((ip,port));
          }
        }
      }
    });
    return completer.future;
  } 
  @override
  Widget build(BuildContext context) {
    return (hostName.isEmpty && pattern.isEmpty)? Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Text(
          "$status",
          style: GoogleFonts.poppins(
            color: Colors.deepOrange,
            fontSize: 30
          ),
        ),
      ),
    ):(!gmst.hostStartedGame)?Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Host named $hostName found",
                style: GoogleFonts.poppins(
                  color: Colors.deepOrange,
                  fontSize: 30
                ),
              ),
              const SizedBox(height: 30,),
              ElevatedButton(
                onPressed: (){
                  if(joinPressed<1){
                    final msg=jsonEncode({"clientAlloweded":true});
                    tcp?.write(msg);
                    joinPressed++;
                  }
                    setState(() {
                      gameJoinState='JOINED';
                    });
                },
                child: Text(
                  "$gameJoinState",
                  style: GoogleFonts.poppins(
                    color: const Color.fromRGBO(255, 255, 0, 1),
                    fontSize: 40
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(255, 98, 0, 1)
                ),
              ),
            ],
          ),
        ),
      ),
    ):Gamingpage();
  }
}