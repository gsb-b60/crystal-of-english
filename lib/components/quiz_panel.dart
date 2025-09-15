import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show TextStyle;

import '../quiz/quiz_models.dart';
import '../main.dart';

typedef OnAnswer = void Function(bool isCorrect);

class QuizPanel extends PositionComponent
    with TapCallbacks, HasGameRef<MyGame> {
  final QuizQuestion question;
  final OnAnswer onAnswer;

  static const double panelHeightRatio = 0.68;

  late final List<_RectZone> _answerHitZones;

  late final RectangleComponent _dimBg;

  QuizPanel({required this.question, required this.onAnswer})
      : super(priority: 100003);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = gameRef.size;
    position = Vector2.zero();

    final w = size.x;
    final h = size.y;
    final panelH = h * panelHeightRatio;
    final panelY = h - panelH;

    // blur
    _dimBg = RectangleComponent(
      position: Vector2.zero(),
      size: Vector2(w, h),
      paint: ui.Paint()..color = const ui.Color(0x88000000),
      priority: priority - 1,
    );
    await add(_dimBg);

    //full width, h 68%
    await add(RectangleComponent(
      position: Vector2(0, panelY),
      size: Vector2(w, panelH),
      paint: ui.Paint()..color = const ui.Color(0xFF101318),
      priority: priority,
    ));

    final halfW = w * 0.5;

    final qRect = RectangleComponent(
      position: Vector2(0, panelY),
      size: Vector2(halfW, panelH),
      paint: ui.Paint()..color = const ui.Color(0xFF1B2430),
      priority: priority + 1,
    );
    await add(qRect);

    final promptText = TextComponent(
      text: question.prompt,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: ui.Color(0xFFF1F5F9),
          fontSize: 18,
        ),
      ),
      position: Vector2(halfW / 2, panelY + panelH / 2),
      priority: priority + 2,
    );
    await add(promptText);

    final aRect = RectangleComponent(
      position: Vector2(halfW, panelY),
      size: Vector2(halfW, panelH),
      paint: ui.Paint()..color = const ui.Color(0xFF0F172A),
      priority: priority + 1,
    );
    await add(aRect);

    const pad = 12.0;
    final innerW = halfW - pad * 2;
    final innerH = panelH - pad * 2;
    final cellW = (innerW - pad) / 2;
    final cellH = (innerH - pad) / 2;

    _answerHitZones = [];
    for (int i = 0; i < 4; i++) {
      final row = i ~/ 2; // 0..1
      final col = i % 2;  

      final x = halfW + pad + col * (cellW + pad);
      final y = panelY + pad + row * (cellH + pad);

      final btn = RectangleComponent(
        position: Vector2(x, y),
        size: Vector2(cellW, cellH),
        paint: ui.Paint()..color = const ui.Color(0xFF233042),
        priority: priority + 2,
      );
      await add(btn);

      final label = ['', '', '', ''][i];
      final option = question.options[i];

      final labelText = TextComponent(
        text: '$label) $option',
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: ui.Color(0xFFE2E8F0),
            fontSize: 16,
          ),
        ),
        position: Vector2(x + cellW / 2, y + cellH / 2),
        priority: priority + 3,
      );
      await add(labelText);

      _answerHitZones.add(
        _RectZone(index: i, rect: ui.Rect.fromLTWH(x, y, cellW, cellH)),
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final p = event.canvasPosition;
    for (final z in _answerHitZones) {
      if (z.rect.contains(ui.Offset(p.x, p.y))) {
        final correct = z.index == question.correctIndex;
        onAnswer(correct);
        removeFromParent(); 
        break;
      }
    }
  }
}

class _RectZone {
  final int index;
  final ui.Rect rect;
  _RectZone({required this.index, required this.rect});
}
