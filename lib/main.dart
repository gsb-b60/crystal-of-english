// lib/main.dart
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import '/components/tiledobject.dart';
import 'player.dart';
import '/components/collisionmap.dart';
import 'dialog/dialog_manager.dart';
import 'dialog/dialog_overlay.dart';
import 'components/npc.dart';            // lớp Npc đã yêu cầu manager
import 'package:flame_tiled/flame_tiled.dart' as ft;



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    GameWidget(
      game: MyGame(),
      // LƯU Ý: lấy manager từ chính instance game được truyền vào builder
      overlayBuilderMap: {
        DialogOverlay.id: (context, game) {
          final g = game as MyGame;
          return DialogOverlay(manager: g.dialogManager);
        },
      },
    ),
  );
}

class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection{
  late Player player;
  late ft.TiledComponent map;
  late Rect mapBounds;

  // Dialog service (duy nhất)
  final DialogManager dialogManager = DialogManager();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final world = World();
    await add(world);

    map = await ft.TiledComponent.load(
      'map.tmx',
      Vector2.all(16),
      prefix: 'assets/maps/',
      priority: 0,
    );
    await world.add(map);

    final loader = TiledObjectLoader(map, world);
    await loader.loadLayer("house");

    final collision = Collision(map: map, parent: world);
    await collision.loadLayer("collision");

    mapBounds = Rect.fromLTWH(
      0, 0,
      map.tileMap.map.width * 16.0,
      map.tileMap.map.height * 16.0,
    );

    player = Player(position: size / 3);
    await world.add(player);

    // Gắn callback để DialogManager tự mở/đóng overlay
    dialogManager.onRequestOpenOverlay = () => overlays.add(DialogOverlay.id);
    dialogManager.onRequestCloseOverlay = () {
      if (overlays.isActive(DialogOverlay.id)) overlays.remove(DialogOverlay.id);
    };

    // ====== THÊM NPC (NHỚ TRUYỀN manager) ======
    final npc1 = Npc(
      position: Vector2(300, 200),
      manager: dialogManager,               // <<< BẮT BUỘC
      lines: [
        'Xin chào!',
        'Trời hôm nay đẹp ghê.',
        'Bạn muốn nghe chuyện kho báu không?',
      ],
      spriteAsset: 'player.png',
      srcPosition: Vector2(0, 0),
      srcSize: Vector2(80, 80),
      interactLabel: 'Nói',
      interactRadius: 56,
      speakEvery: 4,          // đặt lớn nếu không muốn tự “tám”
      showFor: 2,
      bubbleOffsetY: -6,
      zPriority: 20,
    );
    await world.add(npc1);

    // Ví dụ thêm NPC thứ 2 -> cũng PHẢI có manager:
    // final npc2 = Npc(
    //   position: Vector2(500, 320),
    //   manager: dialogManager,             // <<< ĐỪNG QUÊN
    //   lines: ['Ta là thợ rèn.', 'Cần sửa vũ khí không?'],
    //   spriteAsset: 'player.png',
    //   srcPosition: Vector2(0, 0),
    //   srcSize: Vector2(80, 80),
    //   interactLabel: 'Nói',
    // );
    // await world.add(npc2);

    // Camera
    final camera = CameraComponent(world: world, hudComponents: []);
    await add(camera);
    camera.viewfinder.zoom = 2.5;
    camera.follow(player, maxSpeed: 5000);
    camera.setBounds(Rectangle.fromLTWH(
      0, 0,
      map.tileMap.map.width * 16.0,
      map.tileMap.map.height * 16.0,
    ));

    // Joystick
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
