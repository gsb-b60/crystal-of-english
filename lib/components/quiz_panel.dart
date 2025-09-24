import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/painting.dart' show TextStyle;

import '../quiz/quiz_models.dart';
import '../main.dart';

typedef OnAnswer = void Function(bool isCorrect);

class QuizPanel extends PositionComponent
    with TapCallbacks, HasGameReference<MyGame> {  // <— đổi mixin
  final QuizQuestion question;
  final OnAnswer onAnswer;

  static const double panelHeightRatio = 0.68;

  late final List<_RectZone> _answerHitZones;
  bool _disabled = false;

  late final double _leftW;
  late final double _panelY;
  late final double _panelH;

  QuizPanel({required this.question, required this.onAnswer})
      : super(priority: 100003);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = game.size;                // <— game thay vì gameRef
    position = Vector2.zero();

    final w = size.x;
    final h = size.y;
    _panelH = h * panelHeightRatio;
    _panelY = h - _panelH;

    // nền
    await add(RectangleComponent(
      position: Vector2(0, _panelY),
      size: Vector2(w, _panelH),
      paint: ui.Paint()..color = const ui.Color(0xFF101318),
      priority: priority,
    ));

    // cột trái
    _leftW = w * 0.5;
    await add(RectangleComponent(
      position: Vector2(0, _panelY),
      size: Vector2(_leftW, _panelH),
      paint: ui.Paint()..color = const ui.Color(0xFF1B2430),
      priority: priority + 1,
    ));

    // prompt
    final promptText = TextComponent(
      text: question.prompt,
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: ui.Color(0xFFF1F5F9),
          fontSize: 18,
          height: 1.2,
        ),
      ),
      position: Vector2(_leftW / 2, _panelY + 16),
      priority: priority + 2,
    );
    await add(promptText);

    double yCursor = promptText.position.y + 28;

    // Nút âm thanh (nếu có)
    if ((question.sound ?? '').isNotEmpty) {
      final btn = _SmallButton(
        label: '🔊 Phát âm',
        onPressed: _playSound,
        position: Vector2(12, yCursor),
      );
      await add(btn);
      yCursor += 36;

      // Auto-play chỉ khi type chứa 'sound' (có thể bị chặn trên web nếu chưa có gesture)
      if (question.type.contains('sound')) {
        // không critical nếu bị chặn; người chơi có thể bấm nút
        _playSound();
      }
    }

    // Ảnh (nếu có)
    if ((question.image ?? '').isNotEmpty) {
      try {
        final imgSprite = await Sprite.load(question.image!);
        const pad = 12.0;
        final maxW = _leftW - pad * 2;
        final desiredH = _panelH * 0.5;
        final aspect = imgSprite.srcSize.x / imgSprite.srcSize.y;
        final displayW = (maxW).clamp(60, maxW);
        final displayH = (displayW / aspect).clamp(60, desiredH);

        final imageComp = SpriteComponent(
          sprite: imgSprite,
          size: Vector2(displayW.toDouble(), displayH.toDouble()),
          anchor: Anchor.topCenter,
          position: Vector2(_leftW / 2, yCursor),
          priority: priority + 2,
        );
        await add(imageComp);
        yCursor += displayH.toDouble() + 8;
      } catch (e) {
        // In ra console để debug nếu sai đường dẫn assets
        // ignore: avoid_print
        print('Không load được ảnh: ${question.image} — $e');
      }
    }

    // Cột phải (đáp án)
    final rightX = _leftW;
    await add(RectangleComponent(
      position: Vector2(rightX, _panelY),
      size: Vector2(_leftW, _panelH),
      paint: ui.Paint()..color = const ui.Color(0xFF0F172A),
      priority: priority + 1,
    ));

    // Lưới 2x2 đáp án
    const pad = 12.0;
    final innerW = _leftW - pad * 2;
    final innerH = _panelH - pad * 2;
    final cellW = (innerW - pad) / 2;
    final cellH = (innerH - pad) / 2;

    _answerHitZones = [];
    for (int i = 0; i < 4; i++) {
      final row = i ~/ 2;
      final col = i % 2;

      final x = rightX + pad + col * (cellW + pad);
      final y = _panelY + pad + row * (cellH + pad);

      await add(RectangleComponent(
        position: Vector2(x, y),
        size: Vector2(cellW, cellH),
        paint: ui.Paint()..color = const ui.Color(0xFF233042),
        priority: priority + 2,
      ));

      final option = question.options[i];

      await add(TextComponent(
        text: option,
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: ui.Color(0xFFE2E8F0),
            fontSize: 16,
          ),
        ),
        position: Vector2(x + cellW / 2, y + cellH / 2),
        priority: priority + 3,
      ));

      _answerHitZones.add(
        _RectZone(index: i, rect: ui.Rect.fromLTWH(x, y, cellW, cellH)),
      );
    }
  }

  void _playSound() {
    final s = question.sound;
    if (s == null || s.isEmpty) return;
    // Trên web auto-play có thể bị chặn; bấm nút sẽ phát OK.
    FlameAudio.play(s);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_disabled) return;
    final p = event.canvasPosition;
    for (final z in _answerHitZones) {
      if (z.rect.contains(ui.Offset(p.x, p.y))) {
        _disabled = true;
        final correct = z.index == question.correctIndex;
        onAnswer(correct);
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

class _SmallButton extends PositionComponent with TapCallbacks {
  final String label;
  final void Function() onPressed;

  _SmallButton({
    required this.label,
    required this.onPressed,
    required Vector2 position,
  }) : super(position: position, size: Vector2(112, 28), priority: 100004);

  bool _down = false;

  @override
  void render(ui.Canvas canvas) {
    final bg = ui.Paint()
      ..color = _down ? const ui.Color(0xFF334155) : const ui.Color(0xFF475569);
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(size.toRect(), const ui.Radius.circular(6)),
      bg,
    );

    final tp = TextPaint(
      style: const TextStyle(color: ui.Color(0xFFF8FAFC), fontSize: 14),
    );
    tp.render(canvas, label, size / 2, anchor: Anchor.center);
  }

  @override
  void onTapDown(TapDownEvent event) => _down = true;
  @override
  void onTapCancel(TapCancelEvent event) => _down = false;
  @override
  void onTapUp(TapUpEvent event) {
    _down = false;
    onPressed();
  }
}
