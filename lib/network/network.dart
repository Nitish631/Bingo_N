import 'dart:async';
import 'dart:io';

class Network {
    final int _tcpPort=4040;
    final int _udpPort=4545;
    final String _udpTag='I AM HOST';
    static final Network instance=Network._init();
    Network._init();
    int get tcpPort => _tcpPort;
    int get udpPort=>_udpPort;
    String get udpTag=>_udpTag;
  Future<String> getLocalIPv4()async{
    final ifaces=await NetworkInterface.list(
      includeLoopback: false,type: InternetAddressType.IPv4
    );
    for( final ni in ifaces){
      for(final a in ni.addresses){
        if(!a.isLoopback && a.type==InternetAddressType.IPv4){
          return a.address;
        }
      }
    }
    return '192.168.43.1';
  }
   StreamSubscription<T> cancelOn<T>(
  StreamSubscription<T> sub, void Function() onCancel){
    sub.asFuture().whenComplete(onCancel);
    return sub;
  }
}