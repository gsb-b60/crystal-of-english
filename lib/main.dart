// main.dart
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'tiledobject.dart';
import 'player.dart';
import 'collisionmap.dart';
import 'npc.dart'; 
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
        DialogOverlay.id: (context, game) =>
            DialogOverlay(game: game as MyGame),
      },
    ),
  );
}
class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Player player;
  late ft.TiledComponent map;
  late Rect mapBounds;

  final ValueNotifier<String> dialogText = ValueNotifier<String>('');
  void showDialogText(String text, {double durationSec = 2}) {
    dialogText.value = text;
    overlays.add(DialogOverlay.id);
    Future.delayed(Duration(milliseconds: (durationSec * 1000).round()), () {
      if (overlays.isActive(DialogOverlay.id)) {
        overlays.remove(DialogOverlay.id);
      }
    });
  }

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

    final npc1 = Npc(
      position: tileCenter(40, 7), 
      lines: [
        'Trời hôm nay đẹp ghê!',
        'Nghe nói trong làng có kho báu...',
        'Ngủ trưa xíu đã...',
      ],
      speakEvery: 4,  
      showFor: 2,     
      bubbleOffsetY: -6, 
      zPriority: 20,  
      spriteAsset: 'player.png',
      srcPosition: Vector2(0, 0),   
      srcSize: Vector2(80, 80),
    );
    final npc2 = Npc(
      position: tileCenter(25, 18), // đặt đúng tâm ô (25,18) nếu map 16px
      lines: [
        'Bánh mì nóng mới ra lò!',
        'Ai mua hoa quả không~',
      ],
      speakEvery: 5,
      showFor: 2.2,
      onlyTalkNearPlayer: true, // chỉ nói khi người chơi lại gần
      talkRadius: 180,
      bubbleOffsetY: 0, // sát trên đầu
      zPriority: 20,
      spriteAsset: 'player.png',
      srcPosition: Vector2(80, 0), // ví dụ frame kế tiếp
      srcSize: Vector2(80, 80),
    );
    final npc3 = Npc(
      position: tileCenter(32, 10), // một NPC khác đặt theo ô
      lines: [
        'Cẩn thận khu rừng phía bắc!',
        'Đêm nay trăng tròn đó.',
      ],
      speakEvery: 6,
      showFor: 2,
      bubbleOffsetY: -10,
      zPriority: 30, // cao hơn để không bị tán cây/mái nhà che
      spriteAsset: 'player.png',
      srcPosition: Vector2(160, 0),
      srcSize: Vector2(80, 80),
    );

    await world.addAll([npc1, npc2, npc3]);
    final camera = CameraComponent(world: world, hudComponents: []);
    await add(camera);
    camera.viewfinder.zoom = 2.5;
    camera.follow(player, maxSpeed: 5000);
    camera.setBounds(Rectangle.fromLTWH(
      0, 0,
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

class DialogOverlay extends StatelessWidget {
  static const id = 'dialog';
  final MyGame game;
  const DialogOverlay({super.key, required this.game});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ValueListenableBuilder<String>(
              valueListenable: game.dialogText,
              builder: (context, text, _) {
                return Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.3,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
