import 'dart:io';

import 'package:bingo_n/GameData/GameData.dart';
import 'package:bingo_n/database/userInfo.dart';
import 'package:bingo_n/screen/RolePage.dart';
import 'package:bingo_n/screen/nameInput.dart';
import 'package:flutter/material.dart';

class PreGamePage extends StatefulWidget {
  const PreGamePage({super.key});

  @override
  State<PreGamePage> createState() => _PreGamePageState();
}

class _PreGamePageState extends State<PreGamePage> {
  GameData gameData = GameData.instance;
  @override
  void initState() {
    super.initState();
    sleep(Duration(milliseconds: 300));
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userData = UserDatabase.instance;
    String? name = await userData.getUserName();
    if (name != null) {
      gameData.name = name;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Rolepage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NameInputPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
