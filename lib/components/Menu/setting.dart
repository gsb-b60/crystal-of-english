import 'package:flutter/material.dart';
import 'package:mygame/main.dart';

class Setting extends StatelessWidget {
  final MyGame game;
  const Setting({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("setting")),
      body: Center(child: Text("hello world")),
    );
  }
}
