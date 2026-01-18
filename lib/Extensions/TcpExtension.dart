import 'dart:convert';
import 'dart:io';

extension SocketLines on Socket{
  Stream<String> get lines=> cast<List<int>>().transform(const Utf8Decoder()).transform(const LineSplitter());
}