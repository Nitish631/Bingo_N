import 'dart:convert';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
class UserDatabase{
  static final UserDatabase instance=UserDatabase._init();
  UserDatabase._init();
  static sqflite.Database? _database;
  Future<sqflite.Database> get database async{
    if(_database!=null) return _database!;
    _database=await _initDB('user.db');
    return _database!;
  }
  Future<sqflite.Database> _initDB(String filePath)async{
    final pathDirectory= await sqflite.getDatabasesPath();
    final path =join(pathDirectory,filePath);
    return await sqflite.openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
  Future _createDB(sqflite.Database db,int version) async{
    await db.execute('''
      CREATE TABLE user(
        id INTEGER PRIMARY KEY,
        name TEXT,
        pattern TEXT NOT NULL      
      )
    ''');
    await db.insert('user',{'id':1,'name':'','pattern':jsonEncode([23,16,7,11,20,10,5,12,4,17,19,15,1,21,22,6,2,14,3,24,13,25,8,9,18])});
  }
  Future<void> updateName(String name)async{
    final db =await database;
    await db.update('user',{'name':name},where: 'id=?',whereArgs: [1]);
  }
  Future<bool> updatePattern(List<int> pattern)async{
    final db =await database;
    final result= await db.update('user',{'pattern':jsonEncode(pattern)},where:'id=?',whereArgs:[1]);
    return result>0;
  }
  Future<String> getUserName() async{
    final db =await database;
    final result=await db.query('user',where: 'id=?',whereArgs: [1]);
    final user=result.first;
    return user['name'] as String;
  }
  Future<List<int>> getStoredPattern()async{
    final db=await database;
    final result=await db.query(
      'user',
      columns: ['pattern'],
      where: 'id=?',
      whereArgs: [1],
      limit: 1
    );
    if(result.isEmpty){
      throw Exception('User not found');
    }
    final patternJson=result.first['pattern'] as String;
    return List<int>.from(jsonDecode(patternJson));
  }
}