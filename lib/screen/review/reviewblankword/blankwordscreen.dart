import 'package:flutter/material.dart';

class BlankWordScreen extends StatefulWidget {
  const BlankWordScreen({super.key});

  @override
  State<BlankWordScreen> createState() => _BlankWordScreenState();
}

class _BlankWordScreenState extends State<BlankWordScreen> {
  final String word = "era";
  List<Widget> CreateChar(word) {
    List<Widget> list = <Widget>[];
    for (int i = 0; i < word.length; i++) {
      list.add(ElevatedButton(onPressed: () {}, child: Text(word[i])));
    }
    list.shuffle();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("blank")),
      body: Column(
        children: [
          Center(child: Container(width: 400, height: 200,decoration: BoxDecoration(
            color:Color.fromARGB(255, 77, 138, 187)
          ),)),
          Expanded(
            child: Center(child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: CreateChar("Hello"))),
          ),

          Center(child: Text("let go hello world my name is blank!")),
        ],
      ),
    );
  }
}
