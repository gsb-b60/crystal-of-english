import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'tiledobject.dart';
import 'player.dart';
import 'package:flame/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(GameWidget(game: MyGame()));
}
class MyGame extends FlameGame with HasKeyboardHandlerComponents {
  late Player player;
  late TiledComponent map;
  late Rect mapBounds;
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final world = World();
    await add(world);
    map = await TiledComponent.load(
      'map.tmx',
      Vector2.all(16),
      prefix: 'assets/maps/',
      priority: 0,
    )..debugMode = true;
    await world.add(map);
    final loader = TiledObjectLoader(map, world);
    await loader.loadLayer("house");

    mapBounds = Rect.fromLTWH(
      0,
      0,
      map.tileMap.map.width * 16.0,
      map.tileMap.map.height * 16.0,
    );
    // player
    player = Player(position: size / 3);
    await world.add(player);

    //camera
    final camera = CameraComponent(world: world, hudComponents: []);
    await add(camera);

    camera.viewfinder.zoom = 2.5;
    camera.follow(player, maxSpeed: 200);
    camera.setBounds(Rectangle.fromLTWH(
      0,
      0,
      map.tileMap.map.width * 16.0,
      map.tileMap.map.height * 16.0,
    ));

    //joystick
    final joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 30,
        paint: Paint()..color = Colors.blue.withOpacity(0.5),
      ),
      background: CircleComponent(
        radius: 60,
        paint: Paint()..color = Colors.grey.withOpacity(0.3),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    camera.viewport.add(joystick);
    player.joystick = joystick;
  }
}