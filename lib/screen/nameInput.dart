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
  late String myName;
  String labelText = "Player Name:";
  Color labelStyleColor=Colors.brown;

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
    if (enteredName.isEmpty) {
      setState(() {
        labelStyleColor=Colors.red;
        labelText = "Name is compulsary.";
      });
      return;
    }
    await dbInst.updateName(enteredName);
    myName = enteredName;
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
            gradient: LinearGradient(
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
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 250,
                    padding: EdgeInsets.symmetric(horizontal: 5,vertical: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.cyanAccent.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: TextField(
                        onTap: () {
                          setState(() {
                            labelStyleColor=Colors.brown;
                            labelText = "Player Name:";
                          });
                        },
                        controller: nameFieldController,
                        focusNode: nameFocus,
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.cyanAccent.shade100,
                          labelText: labelText,
                          labelStyle: TextStyle(
                            color: labelStyleColor,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none
                          )
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 120,
                    height: 50,
                    child: TextButton(
                      onPressed: _saveName,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                        ),
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
