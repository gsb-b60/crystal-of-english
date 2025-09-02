import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/events.dart';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart'; 
import 'package:flutter/animation.dart' show Curves; 
import '../main.dart' show MyGame;
import '../ui/health.dart'; // Import Health

class BattleResult {
  final String outcome; // 'win' | 'lose' | 'escape'
  BattleResult(this.outcome);
  static BattleResult win() => BattleResult('win');
  static BattleResult lose() => BattleResult('lose');
  static BattleResult escape() => BattleResult('escape');
}

typedef BattleEndCallback = void Function(BattleResult result);

class BattleScene extends Component with HasGameRef<MyGame> {
  final BattleEndCallback onEnd;
  BattleScene({required this.onEnd});
  late final World world;
  late final CameraComponent cam;
  late final PositionComponent hud;
  late Health heroHealth;
  int enemyHp = 12, enemyMax = 12;
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
    final spriteSize = Vector2(320, 180);
    final screenSize = gameRef.size;
    final scale = min(screenSize.x / spriteSize.x, screenSize.y / spriteSize.y);
    final bg = SpriteComponent(
      sprite: bgSprite,
      size: spriteSize * scale, 
      anchor: Anchor.center,
      position: Vector2.zero(),
      priority: 0,
    );
    await world.add(bg);
    hero = SpriteComponent(
      sprite: await Sprite.load('characters/maincharacter/hero.png'),
      size: Vector2(48, 48),
      anchor: Anchor.bottomCenter,
      position: Vector2(-70, 40),
      priority: 10,
    );
    await world.add(hero);
    await world.add(_shadowAt(hero.position, z: 9));

    enemy = SpriteComponent(
      sprite: await Sprite.load('Joanna.png'),
      size: Vector2(48, 48),
      anchor: Anchor.bottomCenter,
      position: Vector2(70, 40),
      priority: 10,
    )..scale = Vector2(-1, 1);
    await world.add(enemy);
    await world.add(_shadowAt(enemy.position, z: 9));

    // HUD
    hud = PositionComponent(priority: 100000);
    await cam.viewport.add(hud);

    // Thanh máu 
    heroHealth = Health(
      maxHearts: 5,
      currentHearts: 5,
      fullHeartAsset: 'hp/heart.png',
      emptyHeartAsset: 'hp/empty_heart.png',
      heartSize: 32,
      spacing: 6,
      margin: const EdgeInsets.only(left: 16, top: 16), 
    );
    await hud.add(heroHealth);
    await hud.add(
      HpBar(
        position: Vector2(screenSize.x - 12 - 120, 10), // Đặt bên phải
        size: Vector2(120, 10),
        getRatio: () => enemyHp / enemyMax,
        label: '',
        alignRight: true,
      ),
    );

    //điều khiển battle
    await hud.addAll([
      TextButtonHud(
        label: 'Tấn công',
        position: Vector2(12, screenSize.y - 40), 
        onPressed: () async => _playerAttack(),
      ),
      TextButtonHud(
        label: 'Chạy',
        position: Vector2(90, screenSize.y - 40),
        onPressed: () => onEnd(BattleResult.escape()),
      ),
    ]);
  }

  Future<void> _playerAttack() async {
    await _dash(hero, towards: enemy.position, offset: Vector2(-12, 0));
    final dmg = _rng.nextInt(3) + 4; // 4..6
    enemyHp = (enemyHp - dmg).clamp(0, enemyMax);
    await _hitFx(enemy.position);
    if (enemyHp <= 0) {
      onEnd(BattleResult.win());
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
    await _enemyAttack();
  }

  Future<void> _enemyAttack() async {
    await _dash(enemy, towards: hero.position, offset: Vector2(12, 0));
    final dmg = _rng.nextInt(3) + 3; 
    heroHealth.damage(1); // dama -1 
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

    await who.add(
      MoveEffect.to(
        mid,
        EffectController(duration: 0.15, curve: Curves.easeOut), 
      ),
    );
    await who.add(
      MoveEffect.to(
        start,
        EffectController(duration: 0.18, curve: Curves.easeIn), 
      ),
    );
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

//thanh hp trên hud
class HpBar extends PositionComponent {
  final double Function() getRatio;
  final String label;
  final bool alignRight;
  HpBar({
    required Vector2 position,
    required Vector2 size,
    required this.getRatio,
    required this.label,
    this.alignRight = false,
  }) : super(position: position, size: size, priority: 100001);

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    final rect = size.toRect();
    //nền
    canvas.drawRect(rect, ui.Paint()..color = const ui.Color(0x66000000));

    final pBorder = ui.Paint()
      ..color = const ui.Color(0xFFFFFFFF)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(rect, pBorder);
    //máu
    final ratio = getRatio().clamp(0.0, 1.0);
    final w = (size.x - 2) * ratio;
    final fillRect = ui.Rect.fromLTWH(1, 1, w, size.y - 2);
    canvas.drawRect(
      fillRect,
      ui.Paint()..color = const ui.Color(0xFFEF5350), // Đỏ
    );
    final textPaint = TextPaint();
    textPaint.render(
      canvas,
      label,
      alignRight ? Vector2(size.x, -12) : Vector2(0, -12),
      anchor: alignRight ? Anchor.topRight : Anchor.topLeft,
    );
  }
}

class TextButtonHud extends PositionComponent with TapCallbacks {
  final String label;
  final void Function() onPressed;

  TextButtonHud({
    required this.label,
    required Vector2 position,
    required this.onPressed,
  }) : super(position: position, size: Vector2(70, 22), priority: 100002);

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

class _ShadowOval extends PositionComponent {
  final double width;
  final double height;
  final int z;

  _ShadowOval({
    required this.width,
    required this.height,
    required Vector2 position,
    this.z = 0,
  }) : super(
         position: position,
         size: Vector2(width, height),
         anchor: Anchor.center,
         priority: z,
       );

  @override
  void render(ui.Canvas canvas) {
    final paint = ui.Paint()..color = const ui.Color(0x22000000);
    final rect = size.toRect().shift(ui.Offset(-size.x / 2, -size.y / 2));
    canvas.drawOval(rect, paint);
  }
}