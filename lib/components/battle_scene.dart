import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/material.dart' show EdgeInsets;

import '../main.dart' show MyGame;
import '../ui/health.dart';
import 'enemy_wander.dart' show EnemyType;

class BattleResult {
  final String outcome; // 'win' | 'lose' | 'escape'
  BattleResult(this.outcome);
  static BattleResult win() => BattleResult('win');
  static BattleResult lose() => BattleResult('lose');
  static BattleResult escape() => BattleResult('escape');
}

typedef BattleEndCallback = void Function(BattleResult result);

class HealthWithRightAlign extends Health {
  HealthWithRightAlign({
    required super.maxHearts,
    super.currentHearts,
    required super.fullHeartAsset,
    required super.emptyHeartAsset,
    super.heartSize = 32,
    super.spacing = 6,
    super.margin = const EdgeInsets.only(right: 16, top: 16),
    super.priority = 100001,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final w = maxHearts * heartSize + (maxHearts - 1) * spacing;
    final h = heartSize;
    size = Vector2(w, h);
    for (var i = 0; i < maxHearts; i++) {
      final icon = children.elementAt(i) as SpriteComponent;
      icon.anchor = Anchor.topLeft;
      icon.position = Vector2(
        (maxHearts - 1 - i) * (heartSize + spacing),
        0,
      );
    }

    setCurrent(currentHearts);
  }
}

class BossHealth extends Health {
  BossHealth({
    required super.maxHearts,
    super.currentHearts,
    required super.fullHeartAsset,
    required super.emptyHeartAsset,
    super.heartSize = 32,
    super.spacing = 6,
    super.margin = const EdgeInsets.only(right: 16, top: 16),
    super.priority = 100001,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final cols = 5;
    final rows = (maxHearts / cols).ceil();
    final w = cols * heartSize + (cols - 1) * spacing;
    final h = rows * heartSize + (rows - 1) * spacing;
    size = Vector2(w, h);
    for (var i = 0; i < maxHearts; i++) {
      final row = i ~/ cols;
      final col = i % cols;
      final icon = children.elementAt(i) as SpriteComponent;
      icon.anchor = Anchor.topLeft;
      icon.position = Vector2(
        (cols - 1 - col) * (heartSize + spacing),
        row * (heartSize + spacing),
      );
    }

    setCurrent(currentHearts);
  }
}

// 2d 
class BattleScene extends Component with HasGameRef<MyGame> {
  final BattleEndCallback onEnd;
  final EnemyType enemyType;

  BattleScene({required this.onEnd, required this.enemyType});

  late final World world;
  late final CameraComponent cam;
  late final PositionComponent hud;

  late Health heroHealth;
  late Health enemyHealth;

  late SpriteComponent hero;
  late SpriteComponent enemy;

  final _rng = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    world = World();
    await add(world);
    cam = CameraComponent(world: world);
    cam.viewfinder.zoom = 2.0;
    await add(cam);
    final bgSprite = await Sprite.load('battlebackground/battle_background.png');
    final logicalBg = Vector2(320, 180); 
    final screenSize = gameRef.size;
    final scale = min(screenSize.x / logicalBg.x, screenSize.y / logicalBg.y);

    final bg = SpriteComponent(
      sprite: bgSprite,
      size: logicalBg * scale,
      anchor: Anchor.center,
      position: Vector2.zero(),
      priority: 0,
    );
    await world.add(bg);

    // Hero (trái)
    hero = SpriteComponent(
      sprite: await Sprite.load('characters/maincharacter/hero.png'),
      size: Vector2(48, 48),
      anchor: Anchor.bottomCenter,
      position: Vector2(-70, 40), // baseline
      priority: 10,
    );
    await world.add(hero);
    await world.add(_shadowAt(hero.position, z: 9));

//flip lật ảnh
    enemy = SpriteComponent(
      sprite: await Sprite.load('Joanna.png'),
      size: Vector2(48, 48),
      anchor: Anchor.bottomCenter,
      position: Vector2(70, 40),
      priority: 10,
    )..scale = Vector2(-1, 1);
    await world.add(enemy);
    await world.add(_shadowAt(enemy.position, z: 9));
    hud = PositionComponent(priority: 100000);
    await cam.viewport.add(hud);

    // heal hero
    heroHealth = Health(
      maxHearts: 5,
      currentHearts: 5,
      fullHeartAsset: 'hp/heart.png',
      emptyHeartAsset: 'hp/empty_heart.png',
      heartSize: 32,
      spacing: 6,
      margin: const EdgeInsets.only(left: 16, top: 16),
    )..anchor = Anchor.topLeft
     ..position = Vector2(16, 16);
    await hud.add(heroHealth);

    //monster type
    final enemyMaxHearts = switch (enemyType) {
      EnemyType.normal   => 2,
      EnemyType.strong   => 3,
      EnemyType.miniboss => 5,
      EnemyType.boss     => 10,
    };

    enemyHealth = (enemyType == EnemyType.boss)
        ? BossHealth(
            maxHearts: enemyMaxHearts,
            currentHearts: enemyMaxHearts,
            fullHeartAsset: 'hp/heart.png',
            emptyHeartAsset: 'hp/empty_heart.png',
            heartSize: 32,
            spacing: 6,
            margin: const EdgeInsets.only(right: 16, top: 16),
          )
        : HealthWithRightAlign(
            maxHearts: enemyMaxHearts,
            currentHearts: enemyMaxHearts,
            fullHeartAsset: 'hp/heart.png',
            emptyHeartAsset: 'hp/empty_heart.png',
            heartSize: 32,
            spacing: 6,
            margin: const EdgeInsets.only(right: 16, top: 16),
          );
//bam goc
    enemyHealth
      ..anchor = Anchor.topRight
      ..position = Vector2(gameRef.size.x - 16, 16);
    await hud.add(enemyHealth);

    // Nút thao tác (đơn giản)
    await hud.addAll([
      TextButtonHud(
        label: 'Tấn công',
        position: Vector2(12, screenSize.y - 40),
        onPressed: () async => _playerAttack(),
      ),
      TextButtonHud(
        label: 'Chạy',
        position: Vector2(100, screenSize.y - 40),
        onPressed: () => onEnd(BattleResult.escape()),
      ),
    ]);
  }

//turnbase
  Future<void> _playerAttack() async {
    await _dash(hero, towards: enemy.position, offset: Vector2(-12, 0));
    enemyHealth.damage(1);
    await _hitFx(enemy.position);
    if (enemyHealth.isDead) {
      onEnd(BattleResult.win());
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
    await _enemyAttack();
  }

  Future<void> _enemyAttack() async {
    await _dash(enemy, towards: hero.position, offset: Vector2(12, 0));
    heroHealth.damage(1); // hero -1 tim
    await _hitFx(hero.position);
    if (heroHealth.isDead) {
      onEnd(BattleResult.lose());
    }
  }

  Future<void> _dash(
    SpriteComponent who, {
    required Vector2 towards,
    required Vector2 offset,
  }) async {
    final start = who.position.clone();
    final mid = Vector2((start.x + towards.x) / 2, (start.y + towards.y) / 2) + offset;

    await who.add(MoveEffect.to(
      mid,
      EffectController(duration: 0.15, curve: Curves.easeOut),
    ));
    await who.add(MoveEffect.to(
      start,
      EffectController(duration: 0.18, curve: Curves.easeIn),
    ));
  }

  Future<void> _hitFx(Vector2 at) async {
    final fx = CircleComponent(
      radius: 8,
      anchor: Anchor.center,
      position: at + Vector2(0, -28),
      paint: ui.Paint()..color = const ui.Color(0x88FFFFFF),
      priority: 20,
    );
    await world.add(fx);
    await fx.add(OpacityEffect.fadeOut(EffectController(duration: 0.15)));
    await Future.delayed(const Duration(milliseconds: 160));
    fx.removeFromParent();
  }

  PositionComponent _shadowAt(Vector2 pos, {int z = 0}) {
    return _ShadowOval(
      width: 36,
      height: 10,
      position: pos + Vector2(0, 2),
      z: z,
    );
  }
}

/// Nút chữ HUD đơn giản
class TextButtonHud extends PositionComponent with TapCallbacks {
  final String label;
  final void Function() onPressed;

  TextButtonHud({
    required this.label,
    required Vector2 position,
    required this.onPressed,
  }) : super(position: position, size: Vector2(80, 24), priority: 100002);

  bool _down = false;

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    final bg = ui.Paint()
      ..color = _down ? const ui.Color(0xFF1B4F72) : const ui.Color(0xFF2E86DE);
    canvas.drawRect(size.toRect(), bg);

    final tp = TextPaint();
    tp.render(canvas, label, size / 2, anchor: Anchor.center);
  }

  @override
  void onTapDown(TapDownEvent event) => _down = true;

  @override
  void onTapUp(TapUpEvent event) {
    _down = false;
    onPressed();
  }

  @override
  void onTapCancel(TapCancelEvent event) => _down = false;
}

/// Bóng chân cho cảm giác đứng trên nền
class _ShadowOval extends PositionComponent {
  final double width;
  final double height;
  final int z;

  _ShadowOval({
    required this.width,
    required this.height,
    required Vector2 position,
    this.z = 0,
  }) : super(position: position, size: Vector2(width, height), anchor: Anchor.center, priority: z);

  @override
  void render(ui.Canvas canvas) {
    final paint = ui.Paint()..color = const ui.Color(0x22000000);
    final rect = size.toRect().shift(ui.Offset(-size.x / 2, -size.y / 2));
    canvas.drawOval(rect, paint);
  }
}
