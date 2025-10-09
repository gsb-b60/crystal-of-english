import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/setting.dart';
import 'package:mygame/main.dart';

class MainMenu extends StatelessWidget {
  final MyGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/menu/background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: MenuContent(game: game),
      ),
    );
  }
}

class MenuContent extends StatelessWidget {
  const MenuContent({super.key, required this.game});

  final MyGame game;

  @override
  Widget build(BuildContext context) {
    return Center(child: MenuNav(game: game));
  }
}

class MenuNav extends StatelessWidget {
  const MenuNav({super.key, required this.game});

  final MyGame game;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 140, child: Image.asset("assets/menu/game_name.png")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero, // bỏ padding mặc định
            backgroundColor: Colors.transparent, // nền trong suốt
            shadowColor: Colors.transparent,
          ),
          onPressed: () {
            game.overlays.remove('MainMenu'); // ẩn menu
            game.resumeEngine(); // chạy game tiếp
          },
          child: Container(
            height: 40,
            child: Image.asset("assets/menu/NewGame.png"),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.transparent, 
            shadowColor: Colors.transparent,
          ),
          onPressed: () {},
          child: Container(
            height: 40,
            child: Image.asset("assets/menu/Continue.png"),
          ),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero, // bỏ padding mặc định
            backgroundColor: Colors.transparent, // nền trong suốt
            shadowColor: Colors.transparent,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Setting(game: game)));
          },
          child: Container(
            height: 40,
            child: Image.asset("assets/menu/Settings.png"),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero, // bỏ padding mặc định
            backgroundColor: Colors.transparent, // nền trong suốt
            shadowColor: Colors.transparent,
          ),
          onPressed: () {
            game.pauseEngine();
          },
          child: Container(
            height: 40,
            child: Image.asset("assets/menu/Exit.png"),
          ),
        ),
      ],
    );
  }
}
