import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'main.dart';
import 'collisionmap.dart';
class Player extends SpriteComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  JoystickComponent? joystick;
  static const double speed = 50;
  late Image spriteSheet;
  final Vector2 frameSize = Vector2(80, 80);
  double frameTime = 0;
  int currentFrame = 0;
  int currentRow = 1;
  bool facingLeft = false;
  bool collided = false;
  JoystickDirection collisionDirection = JoystickDirection.idle;
  Player({required Vector2 position})
    : super(position: position, size: Vector2.all(80), anchor: Anchor.center);
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    spriteSheet = await gameRef.images.load('player.png');
    sprite = Sprite(
      spriteSheet,
      srcPosition: Vector2(0, frameSize.y),
      srcSize: frameSize,
    );
    add(
      RectangleHitbox(size: Vector2(10, 10), position: Vector2(30, 30))
        ..collisionType = CollisionType.active
        ..debugMode = true,
    );
  }
  @override
  void update(double dt) {
    super.update(dt);
    if (joystick == null) return;
    Vector2 velocity = Vector2.zero();
    bool moveLeft = joystick!.direction == JoystickDirection.left;
    bool moveRight = joystick!.direction == JoystickDirection.right;
    bool moveUp = joystick!.direction == JoystickDirection.up;
    bool moveDown = joystick!.direction == JoystickDirection.down;

    // Joystick input
    if (joystick!.direction != JoystickDirection.idle) {
      if (moveLeft &&
          (!collided || collisionDirection != JoystickDirection.left)) {
        velocity.x = -speed;
        currentRow = 0;
        facingLeft = true;
      } else if (moveRight &&
          (!collided || collisionDirection != JoystickDirection.right)) {
        velocity.x = speed;
        currentRow = 0;
        facingLeft = false;
      } else if (moveUp &&
          (!collided || collisionDirection != JoystickDirection.up)) {
        velocity.y = -speed;
        currentRow = 2;
      } else if (moveDown &&
          (!collided || collisionDirection != JoystickDirection.down)) {
        velocity.y = speed;
        currentRow = 1;
      }
    }
    if (velocity != Vector2.zero()) {
      position += velocity * dt;
      frameTime += dt;
      if (frameTime > 0.12) {
        frameTime = 0;
        currentFrame = (currentFrame + 1) % 8;
      }
    }
    sprite = Sprite(
      spriteSheet,
      srcPosition: Vector2(
        currentFrame * frameSize.x,
        currentRow * frameSize.y,
      ),
      srcSize: frameSize,
    );
    scale.x = facingLeft ? -1 : 1;
    position.clamp(
      Vector2.zero(),
      Vector2(gameRef.mapBounds.width, gameRef.mapBounds.height),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is HitboxComponent) {
      print(
        'Collision detected with HitboxComponent at $intersectionPoints, player position: $position',
      );
      if (!collided) {
        collided = true;
        collisionDirection = joystick?.direction ?? JoystickDirection.idle;
      }
    }
  }
  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is HitboxComponent) {
      print(
        'Collision ended with HitboxComponent at player position: $position',
      );
      collided = false;
      collisionDirection = JoystickDirection.idle;
    }
  }
}
