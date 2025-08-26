import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final map = await TiledComponent.load(
      'map.tmx',
      Vector2.all(16),
      prefix: 'assets/maps/', 
    );

    add(map);
  }
}
