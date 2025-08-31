import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame/events.dart';       
import '../main.dart';

class InteractBadge extends PositionComponent
    with TapCallbacks, HasGameRef<MyGame> {
  final PositionComponent target;
  final VoidCallback onPressed;
  final double radius;    
  final double gapToCenter; 
  final String label;

  final TextPaint textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 10,
      color: Color(0xFF000000),
      fontWeight: FontWeight.w600,
      height: 1.1,
    ),
  );

  bool _show = false;      

  InteractBadge({
    required this.target,
    required this.onPressed,
    this.radius = 56,
    this.gapToCenter = 0,
    this.label = 'Nói',
  }) : super(anchor: Anchor.center, priority: 200);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final tp = textPaint.toTextPainter(label)..layout();
    size = Vector2(tp.width + 12, tp.height + 8);
    _follow();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _follow();

    final p = gameRef.player;
    final dist = p.position.distanceTo(target.position);
    _show = dist <= radius;
  }

  void _follow() {
    if (!target.isMounted) return;
    position = target.position + Vector2(0, gapToCenter);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_show) onPressed();  
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!_show) return;     

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2),
        width: size.x,
        height: size.y,
      ),
      const Radius.circular(8),
    );
    final bg = Paint()..color = const Color(0xFFFFFFFF);
    final border = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(rect, bg);
    canvas.drawRRect(rect, border);

    final tp = textPaint.toTextPainter(label)..layout();
    tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
  }
}
