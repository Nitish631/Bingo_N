import 'package:bingo_n/GameState/state.dart';
import 'package:bingo_n/screen/RolePage.dart';
import 'package:bingo_n/database/userInfo.dart';
import 'package:flutter/material.dart';

class NameInputPage extends StatefulWidget {
  const NameInputPage({super.key});

  @override
  State<NameInputPage> createState() => _NameInputPageState();
}

// String name="";
class _NameInputPageState extends State<NameInputPage> {
  late TextEditingController nameFieldController;
  late FocusNode nameFocus;
  late UserDatabase dbInst;

  @override
  void initState() {
    super.initState();
    nameFieldController = TextEditingController();
    nameFocus = FocusNode()..addListener(() => setState(() {}));
    dbInst = UserDatabase.instance;
  }

  @override
  void dispose() {
    nameFieldController.dispose();
    nameFocus.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final enteredName = nameFieldController.text.trim();
    if (enteredName.isEmpty) return;
    await dbInst.updateName(enteredName);
    final gmst = await GameState.getInstance();
    gmst.userData?['name'] = enteredName;
    myName=enteredName;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Rolepage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient:LinearGradient(
              colors: [
                Color.fromRGBO(255, 0, 160, 1),
                Color.fromRGBO(170, 0, 255, 1),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          height: double.infinity,
          width: double.infinity,
          child: Center(
            child: Container(
              height: 200,
              width: 200,
              // color: Colors.cyanAccent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: nameFieldController,
                    focusNode: nameFocus,
                    style: TextStyle(color: Colors.deepPurple,fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.cyanAccent.shade100,
                      labelText: "Player's Name",
                      labelStyle: TextStyle(color: Colors.brown,fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 150,
                    child: TextButton(
                      onPressed: _saveName,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                        )
                      ),
                      child: Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
