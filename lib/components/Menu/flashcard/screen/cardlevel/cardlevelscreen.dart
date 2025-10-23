import 'package:flutter/material.dart';
import 'package:mygame/main.dart';

class Cardlevelscreen extends StatefulWidget {
  final MyGame game;
  const Cardlevelscreen({super.key, required this.game});

  @override
  State<Cardlevelscreen> createState() => _CardlevelscreenState();
}

class _CardlevelscreenState extends State<Cardlevelscreen> {
  final List<String> entries = <String>['1', '2', '3', '4', '5', '6', '7'];
  final List<String> levelImage = <String>[
    'collo.png',
    'armor.png',
    'attack.png',
    'female.png',
    'beast.png',
    'cart.png',
    'jaw.png',
  ];
  final List<int> colorCodes = <int>[700,600,500,400,300,200,100];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [
                  Color(0xFFB0BEC5), // Light silver
                  Color(0xFF90A4AE), // Medium gray
                  Color(0xFFCFD8DC), // Highlight
                  Color(0xFF607D8B), // Shadow
                ],
                stops: [0.0, 0.3, 0.6, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: IconButton(
              icon: const Icon(Icons.auto_awesome),
              onPressed: () {
                widget.game.overlays.remove('CardLevelScreen');
                widget.game.resumeEngine();
              },
            ),
          ),
        ],
        title: const Text(
          'Card Level Screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              print("i tapped level ${entries[index]}");
            },
            child: Container(
              //height: 300,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 150,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color:Colors.grey[colorCodes[index]]!.withOpacity(0.5), // Shadow color with opacity
                    offset: const Offset(1, 1), 
                    blurRadius: 8,
                    spreadRadius: 2, 
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage('assets/level-titan/${levelImage[index]}'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
            
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Complexity ',
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    Text(
                      'Level ${entries[index]}',
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
