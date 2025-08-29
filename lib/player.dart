import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'main.dart';

class Player extends SpriteComponent with HasGameRef<MyGame> {
  JoystickComponent? joystick;
  static const double speed = 100;
  late Image spriteSheet;
  final frameSize = Vector2(80, 80);
  double frameTime = 0;
  int currentFrame = 0;
  int currentRow = 1; 
  bool facingLeft = false;
  Player({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(80),
          anchor: Anchor.center,
        );
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    spriteSheet = await gameRef.images.load('player.png');
    sprite = Sprite(spriteSheet,
        srcPosition: Vector2(0, frameSize.y),
        srcSize: frameSize);
  }
  @override
  void update(double dt) {
    super.update(dt);
    if (joystick == null) return;
    bool moving = false;
    if (joystick!.direction != JoystickDirection.idle) {
      Vector2 newPosition = position.clone();
      if (joystick!.relativeDelta.x.abs() > joystick!.relativeDelta.y.abs()) {
        if (joystick!.relativeDelta.x > 0) {
          newPosition.x += speed * dt;
          currentRow = 0; 
          facingLeft = false;
        } else {
          newPosition.x -= speed * dt;
          currentRow = 0; 
          facingLeft = true;
        }
      } else {
        if (joystick!.relativeDelta.y > 0) {
          newPosition.y += speed * dt;
          currentRow = 1; 
        } else {
          newPosition.y -= speed * dt;
          currentRow = 2; 
        }
      }
      //clamp map
      newPosition.x = newPosition.x.clamp(0, gameRef.mapBounds.width);
      newPosition.y = newPosition.y.clamp(0, gameRef.mapBounds.height);
      position = newPosition;
      moving = true;
    }

    //animation update
    if (moving) {
      frameTime += dt;
      if (frameTime > 0.12) {
        frameTime = 0;
        currentFrame = (currentFrame + 1) % 8; 
      }
    }
    sprite = Sprite(
      spriteSheet,
      srcPosition: Vector2(currentFrame * frameSize.x, currentRow * frameSize.y),
      srcSize: frameSize,
    );
    //flip horizone
    scale.x = facingLeft ? -1 : 1;
  }
} 


