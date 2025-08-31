// speechbubble.dart
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

class SpeechBubble extends PositionComponent {
  final String text;
  final double minWidth;
  final double maxWidth;
  final double padding;
  final double gapToHead;
  final TextPaint textPaint;
  PositionComponent? target;
  final double cornerRadius = 5;  
  final double borderWidth = 1;  
  final double tailH = 8.0;       
  final double tailW = 12.0;       
  late final TextPainter _painter;

  SpeechBubble({
    required this.text,
    this.target,
    this.minWidth = 48,     
    this.maxWidth = 140,    
    this.padding = 6,
    this.gapToHead = 0,    
    TextPaint? textPaint,
  })  : textPaint = textPaint ??
            TextPaint(
              style: const TextStyle(
                fontSize: 7,             
                color: Color.fromARGB(255, 53, 53, 53), 
                height: 1.2,
              ),
            ),
        super(anchor: Anchor.bottomCenter, priority: 100);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _painter = textPaint.toTextPainter(text);
    _painter.layout(maxWidth: maxWidth);
    final contentW = _painter.width;
    final contentH = _painter.height;
    final boxW = (contentW + padding * 2).clamp(minWidth, double.infinity);
    final boxH = contentH + padding * 2;

    size = Vector2(boxW, boxH);

    _repositionToTarget();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _repositionToTarget();
  }

  void _repositionToTarget() {
    final t = target;
    if (t == null || !t.isMounted) return;
    final headWorldPos = t.position + Vector2(0, -t.size.y / 2 - gapToHead);
    position = headWorldPos;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(cornerRadius),
    );

    final bgPaint = Paint()..color = const Color.fromARGB(255, 235, 232, 232);
    final borderPaint = Paint()
      ..color = const Color.fromARGB(255, 66, 66, 66)                      
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rect, bgPaint);
    canvas.drawRRect(rect, borderPaint);
    final cx = size.x / 2;
    final p1 = Offset(cx - tailW / 2, size.y);
    final p2 = Offset(cx + tailW / 2, size.y);
    final p3 = Offset(cx, size.y + tailH);
    final tailPath = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    canvas.drawPath(tailPath, bgPaint);
    canvas.drawPath(tailPath, borderPaint);
    final textOffset = Offset(
      padding.floorToDouble(),
      padding.floorToDouble(),
    );
    _painter.paint(canvas, textOffset);
  }
}
