import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'tiledobject.dart';
import 'player.dart';
import 'collisionmap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
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

    final collision = Collision(map: map, parent: world);
    await collision.loadLayer("collision");

    mapBounds = Rect.fromLTWH(
      0,
      0,
      map.tileMap.map.width * 16.0,
      map.tileMap.map.height * 16.0,
    );

    player = Player(position: size / 3);
    await world.add(player);

    final camera = CameraComponent(world: world, hudComponents: []);
    await add(camera);

    camera.viewfinder.zoom = 2.5;
    camera.follow(player, maxSpeed: 5000); // Tăng maxSpeed để giảm rung
    camera.setBounds(Rectangle.fromLTWH(
      0,
      0,
      map.tileMap.map.width * 16.0,
      map.tileMap.map.height * 16.0,
    ));

    final joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 30,
        paint: Paint()..color = const Color.fromARGB(255, 200, 230, 255),
      ),
      background: CircleComponent(
        radius: 60,
        paint: Paint()..color = const Color.fromARGB(255, 253, 253, 253),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    camera.viewport.add(joystick);
    player.joystick = joystick;
  }
}