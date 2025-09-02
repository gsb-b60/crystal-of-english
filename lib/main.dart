// lib/main.dart
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/components/tiledobject.dart';
import '/components/collisionmap.dart';

import 'player.dart';
import 'dialog/dialog_manager.dart';
import 'dialog/dialog_overlay.dart';
import 'components/npc.dart';
import 'components/coin.dart';
import 'ui/return_button.dart';
import 'ui/area_title.dart';

import 'package:flame_tiled/flame_tiled.dart' as ft;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'MyFont'),
      home: GameWidget(
        game: MyGame(),
        overlayBuilderMap: {
          DialogOverlay.id: (context, game) {
            final g = game as MyGame;
            return DialogOverlay(manager: g.dialogManager);
          },
          ReturnButton.id: (context, game) {
            final g = game as MyGame;
            return ReturnButton(actions: g.rightActions);
          },
        },
      ),
    ),
  );
}

class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  // World/Map/Camera
  late World world;
  late ft.TiledComponent map;
  late Rect mapBounds;

  // HUD root: tạo NGAY tại khai báo để không bị LateInitializationError
  final PositionComponent hudRoot = PositionComponent(priority: 100000);

  late final CameraComponent gameCamera;   // camera duy nhất

  // Player & input
  late Player player;
  JoystickComponent? joystick;

  // Dialog & HUD actions
  final DialogManager dialogManager = DialogManager();
  final ValueNotifier<List<RightAction>> rightActions =
      ValueNotifier<List<RightAction>>(<RightAction>[]);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // --- World + map khởi đầu ---
    world = World();
    await add(world);

    map = await ft.TiledComponent.load(
      'map.tmx',
      Vector2.all(16),
      prefix: 'assets/maps/',
      priority: 0,
    );
    await world.add(map);

    await _initMapObjects('map.tmx');

    final collision = Collision(map: map, parent: world);
    await collision.loadLayer("collision");

    final mapW = map.tileMap.map.width * 16.0;
    final mapH = map.tileMap.map.height * 16.0;
    mapBounds = Rect.fromLTWH(0, 0, mapW, mapH);

    // --- Player ---
    player = Player(position: Vector2(310, 138));
    await world.add(player);

    // --- Camera (tạo 1 lần, không remove) ---
    gameCamera = CameraComponent(world: world, hudComponents: []);
    await add(gameCamera);
    gameCamera.viewfinder.zoom = 2.5;
    gameCamera.follow(player, maxSpeed: 5000);
    gameCamera.setBounds(Rectangle.fromLTWH(0, 0, mapW, mapH));
    gameCamera.viewfinder.position = player.position;

    // --- HUD root là con của viewport (ổn với Flame 1.31.0) ---
    hudRoot.size = size; // kích thước theo màn hình
    await gameCamera.viewport.add(hudRoot);

    // --- Joystick (add vào HUD root) ---
    joystick = JoystickComponent(
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
    await hudRoot.add(joystick!);
    player.joystick = joystick;

    // --- Title map khởi đầu ---
    await showAreaTitle('Overworld');

    // --- Dialog overlay handlers ---
    dialogManager.onRequestOpenOverlay = () {
      overlays.add(DialogOverlay.id);
      _lockControls(true);
    };
    dialogManager.onRequestCloseOverlay = () {
      if (overlays.isActive(DialogOverlay.id)) {
        overlays.remove(DialogOverlay.id);
      }
      _lockControls(false);
    };
  }

  // HUD theo kích thước màn hình
  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    hudRoot.size = newSize; // hudRoot luôn tồn tại
  }

  // Hiện chữ vào HUD root
  Future<void> showAreaTitle(String text) async {
    await hudRoot.add(AreaTitle(text));
  }

  // Khóa/mở điều khiển khi đang thoại
  void _lockControls(bool lock) {
    final js = joystick;
    if (lock) {
      player.joystick = null;
      if (js != null && js.parent != null) js.removeFromParent();
    } else {
      if (js != null && js.parent == null) {
        hudRoot.add(js); // add lại vào HUD
      }
      if (js != null) player.joystick = js;
    }
  }

  // Tạo object theo map
  Future<void> _initMapObjects(String mapFile) async {
    if (mapFile == 'map.tmx') {
      final loader = TiledObjectLoader(map, world);
      await loader.loadLayer("house");

      // NPC mở map nội thất
      final npc1 = Npc(
        position: Vector2(660, 112),
        manager: dialogManager,
        interactLines: ['Xin chào!', 'Bạn cần gì?'],
        interactOrderMode: InteractOrderMode.alwaysFromStart,
        interactPrompt: 'Bạn muốn làm gì?',
        interactChoices: [
          DialogueChoice(
            'Vào thư viện',
            onSelected: () async {
              dialogManager.close();
              await loadMap('houseinterior.tmx', spawn: Vector2(182, 172));
            },
          ),
          DialogueChoice('Tạm biệt', onSelected: dialogManager.close),
        ],
        idleLines: ['Hmm...', 'Nghe nói phía bắc có kho báu.'],
        enableIdleChatter: true,
        spriteAsset: 'Eleonore.png',
        srcPosition: Vector2(0, 0),
        srcSize: Vector2(64, 64),
        size: Vector2(40, 40),
        avatarAsset: 'assets/images/avatar.png',
        avatarDisplaySize: const Size(162, 162),
        interactRadius: 28,
        zPriority: 20,
      );
      await world.add(npc1);
    }
    // Thêm if khác cho nội thất khác nếu cần
  }

  // Đổi map + coin quay lại map ngoài khi vào nội thất
  Future<void> loadMap(
    String mapFile, {
    required Vector2 spawn, // pixel
    Vector2? spawnTile, // nếu muốn theo tile
    double tileSize = 16,
  }) async {
    // KHÔNG đụng HUD/camera; chỉ thay world/map/player

    // Remove world cũ
    if (world.parent != null) world.removeFromParent();

    // World + map mới
    final newWorld = World();
    await add(newWorld);
    world = newWorld;

    map = await ft.TiledComponent.load(
      mapFile,
      Vector2.all(tileSize),
      prefix: 'assets/maps/',
      priority: 0,
    );
    await world.add(map);

    await _initMapObjects(mapFile);

    final collision = Collision(map: map, parent: world);
    await collision.loadLayer("collision");

    final mapW = map.tileMap.map.width * tileSize;
    final mapH = map.tileMap.map.height * tileSize;
    mapBounds = Rect.fromLTWH(0, 0, mapW, mapH);

    // Spawn
    Vector2 finalSpawn;
    if (spawnTile != null) {
      finalSpawn = Vector2(
        (spawnTile.x + 0.5) * tileSize,
        (spawnTile.y + 0.5) * tileSize,
      );
    } else {
      finalSpawn = spawn;
    }
    finalSpawn = Vector2(
      finalSpawn.x.clamp(0, mapW - player.size.x).toDouble(),
      finalSpawn.y.clamp(0, mapH - player.size.y).toDouble(),
    );

    // Player mới
    if (player.parent != null) player.removeFromParent();
    player = Player(position: finalSpawn);
    await world.add(player);

    // Cập nhật camera để theo world + player mới
    gameCamera.world = world; // (nếu bản của bạn không có setter này, báo mình để đổi sang cách khác)
    gameCamera.follow(player, maxSpeed: 5000);
    gameCamera.setBounds(Rectangle.fromLTWH(0, 0, mapW, mapH));
    gameCamera.viewfinder.position = player.position;

    // Gán joystick lại cho player (HUD vẫn ở viewport)
    if (joystick != null && joystick!.parent == null) {
      await hudRoot.add(joystick!);
    }
    player.joystick = joystick;

    // Title theo map
    await showAreaTitle(mapFile == 'houseinterior.tmx' ? 'Library' : 'Overworld');

    // Coin quay về map ngoài nếu đang ở nội thất
    if (mapFile == 'houseinterior.tmx') {
      await world.add(
        Coin(
          position: finalSpawn.clone(),
          interactRadius: 140,
          onCollected: () async {
            await loadMap('map.tmx', spawn: Vector2(657, 133));
          },
        ),
      );
    }
  }
}
