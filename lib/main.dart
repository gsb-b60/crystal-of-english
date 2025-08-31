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
import 'components/npc.dart';
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
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Player player;
  late ft.TiledComponent map;
  late Rect mapBounds;
  final DialogManager dialogManager = DialogManager();
  JoystickComponent? joystick;
  CameraComponent? gameCamera;
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

    final cam = CameraComponent(world: world, hudComponents: []);
    await add(cam);
    cam.viewfinder.zoom = 2.5;
    cam.follow(player, maxSpeed: 5000);
    cam.setBounds(Rectangle.fromLTWH(
      0, 0,
      map.tileMap.map.width * 16.0,
      map.tileMap.map.height * 16.0,
    ));
    gameCamera = cam; // gán field

    final js = JoystickComponent(
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
    cam.viewport.add(js);
    joystick = js;
    player.joystick = js;

   final npc1 = Npc(
  position: Vector2(660, 112),
  manager: dialogManager,

  interactLines: [
    'Xin chào!',
    'Trời hôm nay đẹp quá.',
    'Em ăn cơm chưa?',
  ],

  // thoại TỰ NÓI (bong bóng lặp)
  idleLines: [
    'Hmm...',
    'Làng này dạo này yên ả ghê.',
    'Nghe đồn có kho báu ở phía bắc.',
  ],
  enableIdleChatter: true,     

  // nhịp tự nói
  idleSpeakEvery: 5,
  idleShowFor: 2,
  idleOnlyNearPlayer: true,
  idleTalkRadius: 120,
  idleBubbleOffsetY: -4,

  // sprite & avatar như trước
  spriteAsset: 'Eleonore.png',
  srcPosition: Vector2(0, 0),
  srcSize: Vector2(64, 64),
  size: Vector2(40, 40),

  avatarAsset: 'assets/images/avatar.png',
  avatarSrcPosition: Vector2(0, 0),
  avatarSrcSize: Vector2(64, 64),
  avatarDisplaySize: Size(96, 96),

  interactRadius: 28,
  interactGapToCenter: 0,
  zPriority: 20,
);
    await world.add(npc1);

    dialogManager.onRequestOpenOverlay = () {
      overlays.add(DialogOverlay.id);
      _lockControls(true);
    };
    dialogManager.onRequestCloseOverlay = () {
      if (overlays.isActive(DialogOverlay.id)) overlays.remove(DialogOverlay.id);
      _lockControls(false);
    };
  }

  void _lockControls(bool lock) {
    if (lock) {
      // ngắt input
      player.joystick = null;

      // ẩn joystick
      final js = joystick;
      if (js != null && js.parent != null) {
        js.removeFromParent();
      }
    } else {
      final js = joystick;
      final cam = gameCamera;

      if (js != null) {
        if (js.parent == null && cam != null) {
          cam.viewport.add(js);
        }
        player.joystick = js;
      }
    }
  }
}
