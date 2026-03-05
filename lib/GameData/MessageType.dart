enum MessageType {
  none,
  automatic,
  clicked;

  String toJson() => name;
  factory MessageType.fromJson(String json) {
    return MessageType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => MessageType.automatic,
    );
  }
}
