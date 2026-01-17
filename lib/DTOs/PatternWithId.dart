class PatternWithId {
  late int id;
  List<int> pattern;
  PatternWithId({required this.id, required this.pattern});

  Map<String, dynamic> toJson() {
    return {'pattern': pattern, 'id': id};
  }

  factory PatternWithId.fromJson(Map<String, dynamic> json) {
    return PatternWithId(
      id: json['id'] is int? json['id'] as int:int.parse(json['id'].toString()),
      pattern: json['pattern'] != null ? List.from(json['pattern']) : [],
    );
  }
}
