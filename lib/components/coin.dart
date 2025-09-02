import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart'; // For VoidCallback

import '../main.dart';  

class Coin extends SpriteAnimationComponent with TapCallbacks {
  final VoidCallback onCollected;
  final double interactRadius;
  Coin({
    required Vector2 position,
    required this.onCollected,
    this.interactRadius = 50.0,  
  }) : super(
         position: position,
         size: Vector2(16, 16),
         anchor: Anchor.center, 
       );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final List<Sprite> sprites = [];
    for (int i = 1; i <= 4; i++) {
      sprites.add(await Sprite.load('coins/coin$i.png'));
    }

    // Tạo animation: chạy liên tục với tốc độ 0.15 giây/frame, lặp vô hạn
    animation = SpriteAnimation.spriteList(
      sprites,
      stepTime: 0.15,
      loop: true,
    );
    priority = 10;  
  }

  @override
  bool onTapUp(TapUpEvent event) {
    // Tìm game instance để lấy player
    final game = findGame() as MyGame?;
    if (game == null || game.player == null) return false;
    final distance = position.distanceTo(game.player.center);

    if (distance <= interactRadius) {
      onCollected(); 
      removeFromParent();  
      return true;  
    }

    return false;  
  }
}