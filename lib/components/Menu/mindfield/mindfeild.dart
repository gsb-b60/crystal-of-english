import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/mindfield/mindfieldui.dart';

class MindFeild extends StatefulWidget {
  const MindFeild({super.key});

  @override
  State<MindFeild> createState() => _MindFeildState();
}

class _MindFeildState extends State<MindFeild> {
  @override
  Widget build(BuildContext context) {
    return MindFeildUI();
  }
}

