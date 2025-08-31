// npc.dart
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'main.dart';
import 'speechbubble.dart';

Vector2 tileCenter(int col, int row, {double tileSize = 16}) =>
    Vector2((col + 0.5) * tileSize, (row + 0.5) * tileSize);

class Npc extends SpriteComponent with HasGameRef<MyGame> {
  final List<String> lines;
  final double speakEvery;        
  final double showFor;            
  final bool blockPath;            
  final bool onlyTalkNearPlayer;  
  final double talkRadius;        
  final double bubbleOffsetY;      
  final String spriteAsset;      
  final Vector2 srcPosition;        
  final Vector2 srcSize;           
  final int zPriority;             

  int _idx = 0;
  SpeechBubble? _bubble;
  final _rnd = Random();

  Npc({
    required Vector2 position,
    required this.lines,
    this.speakEvery = 4,
    this.showFor = 2,

    //hanh vi
    this.blockPath = false,
    this.onlyTalkNearPlayer = false,
    this.talkRadius = 160,
    this.bubbleOffsetY = 0, 

    this.spriteAsset = 'player.png',
    Vector2? srcPosition,           
    Vector2? srcSize,                
    this.zPriority = 20,

    Vector2? size,
  })  : srcPosition = srcPosition ?? Vector2(0, 0),   
        srcSize = srcSize ?? Vector2(80, 80),         
        super(
          position: position,
          size: size ?? Vector2(80, 80),
          anchor: Anchor.center,
          priority: zPriority,
        );
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final img = await game.images.load(spriteAsset);
    sprite = Sprite(img, srcPosition: srcPosition, srcSize: srcSize);

    if (blockPath) {
      add(
        RectangleHitbox(size: Vector2(20, 20), position: Vector2(30, 30))
          ..collisionType = CollisionType.passive,
      );
    }
    final startJitter = _rnd.nextDouble() * 1.5;

    //loop
    final loop = TimerComponent(
      period: speakEvery,
      repeat: true,
      onTick: _speakOnce,
      autoStart: false,
    );
    add(loop);

    add(
      TimerComponent(
        period: startJitter,
        onTick: () {
          _speakOnce();   
          loop.timer.start();
        },
        removeOnFinish: true,
      ),
    );
  }
  Future<void> _speakOnce() async {
    if (lines.isEmpty) return;

    if (onlyTalkNearPlayer) {
      final p = game.player;
      if (p.position.distanceTo(position) > talkRadius) return;
    }
    final text = lines[_idx % lines.length];
    _idx++;
    _bubble?.removeFromParent();
    _bubble = null;
    final bubble = SpeechBubble(
      text: text,
      target: this,
      maxWidth: 160,
      padding: 8,
      gapToHead: bubbleOffsetY,
    );
    final host = parent;
    if (host != null) {
      await host.add(bubble);
      _bubble = bubble;
    }
    add(
      TimerComponent(
        period: showFor,
        onTick: () {
          _bubble?.removeFromParent();
          _bubble = null;
        },
        removeOnFinish: true,
      ),
    );
  }

  void teleportTo(Vector2 p) => position = p;
  void teleportToTile(int col, int row, {double tileSize = 16}) {
    position = tileCenter(col, row, tileSize: tileSize);
  }
  @override
  void onRemove() {
    _bubble?.removeFromParent();
    _bubble = null;
    super.onRemove();
  }
}
