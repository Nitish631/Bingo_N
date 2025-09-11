import 'dart:io';

class BoundedSet {
  final Set<Socket> set = {};

  static final BoundedSet _instance=BoundedSet._init();
  BoundedSet._init();
  static BoundedSet get instance=> _instance;

  bool add(Socket value) {
    if (set.length > 6) return false;
    return set.add(value);
  }

  bool remove(Socket value) => set.remove(value);
  bool isEmpty(){
    return set.isEmpty;
  }
  Set<Socket> get values => set;
  @override
  String toString()=>set.toString();
}
