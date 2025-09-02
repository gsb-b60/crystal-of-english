import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../main.dart';

class InteractBadge extends PositionComponent
    with TapCallbacks, HasGameRef<MyGame> {
  final PositionComponent target;
  final VoidCallback onPressed;
  final double radius;      
  final double gapToCenter; 

  bool _enabled = false;    

  InteractBadge({
    required this.target,
    required this.onPressed,
    this.radius = 56,
    this.gapToCenter = 0,
  }) : super(anchor: Anchor.center, priority: 200);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2.all(radius * 2);
    _follow();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _follow();

    //bán kính
    final p = gameRef.player;
    final dist = p.position.distanceTo(target.position);
    _enabled = dist <= radius;
  }

  void _follow() {
    if (!target.isMounted) return;
    position = target.position + Vector2(0, gapToCenter);
  }

  //nhận tap nếu tap nằm trong bounds của component
  @override
  void onTapDown(TapDownEvent event) {
    if (_enabled) onPressed();
  }

  //invisible
  @override
  void render(Canvas canvas) {
    // intentionally empty
    // (Muốn debug vùng tap, bỏ comment 3 dòng dưới)
    // final paint = Paint()..color = const Color(0x22FF0000);
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..style=PaintingStyle.stroke);
  }
}
