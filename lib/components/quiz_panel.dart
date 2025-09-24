// lib/components/quiz_panel.dart
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/cache.dart' show Images;          // <- dùng Images riêng
import 'package:flutter/painting.dart' show TextStyle;
import 'package:flutter/foundation.dart' show VoidCallback;

import '../quiz/quiz_models.dart';
import '../main.dart';

typedef OnAnswer = void Function(bool isCorrect);

class QuizPanel extends PositionComponent
    with TapCallbacks, HasGameReference<MyGame> {
  final QuizQuestion question;
  final OnAnswer onAnswer;

  static const double panelHeightRatio = 0.68;

  bool _disabled = false;

  // cột trái:
  late final double _leftW;
  late final double _panelY;
  late final double _panelH;

  QuizPanel({required this.question, required this.onAnswer})
      : super(priority: 100003);

  // ==== Helpers ============================================================

  // Chuẩn hoá path: thêm 'assets/' nếu thiếu
  String _asset(String p) => p.startsWith('assets/') ? p : 'assets/$p';

  // Load Sprite "bất chấp" prefix global: dùng Images(prefix: '')
  Future<Sprite?> _loadSpriteAny(String rawPath) async {
    final candidates = <String>[
      rawPath,
      _asset(rawPath),
    ];
    final images = Images(prefix: ''); // không gắn thêm gì hết
    for (final path in candidates) {
      try {
        // debug cho chắc
        // ignore: avoid_print
        print('[QuizPanel] Try load image: $path');
        final img = await images.load(path);
        return Sprite(img);
      } catch (_) {
        // tiếp tục thử candidate tiếp theo
      }
    }
    // ignore: avoid_print
    print('[QuizPanel] Image NOT FOUND with any candidate: $candidates');
    return null;
  }

  Future<void> _playSoundSafe(String rawPath) async {
    final p = _asset(rawPath); // ép có 'assets/...'
    try {
      await FlameAudio.audioCache.load(p); // preload (không bắt buộc)
      await FlameAudio.play(p);
    } catch (e) {
      // ignore: avoid_print
      print('[QuizPanel] Cannot play sound: $p — $e');
    }
  }

  // =======================================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = game.size;
    position = Vector2.zero();

    final w = size.x;
    final h = size.y;
    _panelH = h * panelHeightRatio;
    _panelY = h - _panelH;

    // Nền panel
    await add(RectangleComponent(
      position: Vector2(0, _panelY),
      size: Vector2(w, _panelH),
      paint: ui.Paint()..color = const ui.Color(0xFF101318),
      priority: priority,
    ));

    // Cột trái (prompt + image + sound)
    _leftW = w * 0.5;

    await add(RectangleComponent(
      position: Vector2(0, _panelY),
      size: Vector2(_leftW, _panelH),
      paint: ui.Paint()..color = const ui.Color(0xFF1B2430),
      priority: priority + 1,
    ));

    // Prompt
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
    final soundPath = (question.sound ?? '').trim();
    if (soundPath.isNotEmpty) {
      final btn = _SmallButton(
        label: '🔊 Phát âm',
        onPressed: () => _playSoundSafe(soundPath),
        position: Vector2(12, yCursor),
      );
      await add(btn);
      yCursor += 36;

      if (question.type.contains('sound')) {
        _playSoundSafe(soundPath); // auto play — nếu bị chặn thì user ấn nút
      }
    }

    // Ảnh (nếu có)
    final imagePath = (question.image ?? '').trim();
    if (imagePath.isNotEmpty) {
      final sprite = await _loadSpriteAny(imagePath);
      if (sprite != null) {
        const pad = 12.0;
        final maxW = _leftW - pad * 2;
        final desiredH = _panelH * 0.5;

        final aspect = sprite.srcSize.x / sprite.srcSize.y;
        final displayW = maxW; // full theo bề ngang cột trái
        final displayH = (displayW / aspect).clamp(60, desiredH);

        final imageComp = SpriteComponent(
          sprite: sprite,
          size: Vector2(displayW, displayH.toDouble()),
          anchor: Anchor.topCenter,
          position: Vector2(_leftW / 2, yCursor),
          priority: priority + 2,
        );
        await add(imageComp);
        yCursor += displayH.toDouble() + 8;
      } else {
        // hiện một nhãn báo lỗi nhỏ (khỏi đen màn)
        await add(TextComponent(
          text: 'Image not found:\n${_asset(imagePath)}',
          anchor: Anchor.topLeft,
          textRenderer: TextPaint(
            style: const TextStyle(color: ui.Color(0xFFEF4444), fontSize: 12),
          ),
          position: Vector2(12, yCursor),
          priority: priority + 2,
        ));
        yCursor += 28;
      }
    }

    // Cột phải (đáp án) — 4 nút chia đều, có margin + gap
    final rightX = _leftW;
    await add(RectangleComponent(
      position: Vector2(rightX, _panelY),
      size: Vector2(_leftW, _panelH),
      paint: ui.Paint()..color = const ui.Color(0xFF0F172A),
      priority: priority + 1,
    ));

    const double marginH = 16.0; // trái/phải
    const double marginV = 16.0; // trên/dưới
    const int count = 4;
    const double gap = 8.0; // khoảng hở giữa các nút

    final double innerW = _leftW - marginH * 2;
    final double innerH = _panelH - marginV * 2;
    final double startX = rightX + marginH;
    double rowY = _panelY + marginV;

    final double rowH = (innerH - gap * (count - 1)) / count;

    for (int i = 0; i < count; i++) {
      final displayLabel = '${i + 1}. ${question.options[i]}';
      await add(_AnswerItem(
        rect: ui.Rect.fromLTWH(startX, rowY, innerW, rowH),
        label: displayLabel,
        priority: priority + 3,
        onTap: () {
          if (_disabled) return;
          _disabled = true;
          onAnswer(i == question.correctIndex);
        },
      ));
      rowY += rowH + gap;
    }
  }
}

/// ====== Các lớp con hỗ trợ ======

class _SmallButton extends PositionComponent with TapCallbacks {
  final String label;
  final VoidCallback onPressed;

  _SmallButton({
    required this.label,
    required this.onPressed,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(112, 28),
          priority: 100004,
        );

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

class _AnswerItem extends PositionComponent with TapCallbacks {
  final String label;
  final VoidCallback onTap;

  _AnswerItem({
    required ui.Rect rect,
    required this.label,
    required int priority,
    required this.onTap,
  }) : super(
          position: Vector2(rect.left, rect.top),
          size: Vector2(rect.width, rect.height),
          anchor: Anchor.topLeft,
          priority: priority,
        );

  bool _down = false;

  @override
  void render(ui.Canvas canvas) {
    final rrect = ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(0, 0, size.x, size.y),
      const ui.Radius.circular(12),
    );

    final fill = ui.Paint()
      ..color = _down
          ? const ui.Color(0xFF2A3647)  // nhấn
          : const ui.Color(0xFF233042); // thường
    canvas.drawRRect(rrect, fill);

    final border = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const ui.Color(0x33FFFFFF);
    canvas.drawRRect(rrect, border);

    final tp = TextPaint(
      style: const TextStyle(
        color: ui.Color(0xFFE2E8F0),
        fontSize: 16,
        height: 1.1,
      ),
    );
    tp.render(canvas, label, Vector2(12, size.y / 2), anchor: Anchor.centerLeft);
  }

  @override
  void onTapDown(TapDownEvent event) => _down = true;
  @override
  void onTapCancel(TapCancelEvent event) => _down = false;
  @override
  void onTapUp(TapUpEvent event) {
    _down = false;
    onTap();
  }
}
