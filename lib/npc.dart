import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

class NPC extends SpriteComponent with HasGameRef {
  final Vector2 velocity;
  final double tileSize = 16.0;
  final int totalTiles = 8;
  double currentTile = 0.0;

  NPC({
    required Vector2 position,
    required this.velocity,
    required Vector2 size,
  }) : super(position: position, size: size, priority: 1);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      sprite = await Sprite.load('npc.png');
      print('Loaded npc.png as sprite. Size: ${size.x}x${size.y}, Position: ${position.x},${position.y}');
    } catch (e) {
      print('Lỗi khi tải npc.png: $e');
      rethrow;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += velocity * dt;
    currentTile += (velocity.length * dt) / tileSize;

    if (currentTile >= totalTiles) {
      velocity.negate();
      currentTile = 0.0;
    } else if (currentTile <= 0) {
      velocity.negate();
      currentTile = 0.0;
    }

    print('NPC position: ${position.x},${position.y}, Velocity: ${velocity.x},${velocity.y}');
  }
}