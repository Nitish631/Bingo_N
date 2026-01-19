enum Status{
  idle,
  discovering,
  connecting,
  connected,
  disconnected,
  error,
}
class ConnectionStatus {
  Status _status=Status.idle;
  String? _message;
  Status get status=>_status;
  String? get message=>_message;
  static ConnectionStatus instance=ConnectionStatus._init();
  ConnectionStatus._init();

  void setStatus(Status status,{String? message}){
    _status=status;
    _message=message;
  }
  void reset(){
    _status =Status.idle;
    _message=null;
  }
}