// lib/components/quiz_panel.dart
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
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

  // layout
  late final double _leftW;
  late final double _panelY;
  late final double _panelH;

  QuizPanel({required this.question, required this.onAnswer})
      : super(priority: 100003);

  // ===== Load image (ui.Image) trực tiếp từ bundle =====
  Future<ui.Image?> _loadUiImage(String raw) async {
    final candidates = <String>[
      raw,
      if (!raw.startsWith('assets/')) 'assets/$raw',
    ];
    for (final p in candidates) {
      try {
        final ByteData data = await rootBundle.load(p);
        final bytes = data.buffer.asUint8List();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        return frame.image;
      } catch (_) {}
    }
    // debug:
    // ignore: avoid_print
    print('[QuizPanel] Image NOT FOUND: $raw (tried: $candidates)');
    return null;
  }

  Future<void> _playSoundRaw(String raw) async {
    try {
      // prefix đã set 'assets/' trong main()
      await FlameAudio.play(raw);
    } catch (e) {
      // ignore: avoid_print
      print('[QuizPanel] Cannot play sound: $raw — $e');
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = game.size;
    position = Vector2.zero();

    final w = size.x;
    final h = size.y;
    _panelH = h * panelHeightRatio;
    _panelY = h - _panelH;

    // nền tổng
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

    // cột phải (đáp án)
    final rightX = _leftW;
    await add(RectangleComponent(
      position: Vector2(rightX, _panelY),
      size: Vector2(_leftW, _panelH),
      paint: ui.Paint()..color = const ui.Color(0xFF0F172A),
      priority: priority + 1,
    ));

    // LEFT column theo type
    final type = (question.type).toLowerCase();
    final hasImage = (question.image ?? '').trim().isNotEmpty;
    final hasSound = (question.sound ?? '').trim().isNotEmpty;

    if (type == 'text') {
      await _addCenteredText(question.prompt);
    } else if (type == 'image') {
      if (hasImage) await _addImageCentered((question.image!).trim());
    } else if (type == 'imagesound' || type == 'image_sound') {
      await _addImageSoundWithTitle(
        title: question.prompt,        // <<< text ở trên
        imageRaw: hasImage ? (question.image!).trim() : null,
        soundRaw: hasSound ? (question.sound!).trim() : null,
      );
    } else if (type == 'sound') {
      if (hasSound) await _addSoundButtonCentered((question.sound!).trim());
    } else {
      await _addCenteredText(question.prompt);
    }

    // RIGHT column: 4 đáp án chia đều, gap đẹp
    const double marginH = 16.0;
    const double marginV = 16.0;
    const double gap = 8.0;
    const int count = 4;

    final innerW = _leftW - marginH * 2;
    final innerH = _panelH - marginV * 2;
    final startX = rightX + marginH;
    double rowY = _panelY + marginV;
    final rowH = (innerH - gap * (count - 1)) / count;

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

  // -------- LEFT BUILDERS --------

  Future<void> _addCenteredText(String text) async {
    await add(TextComponent(
      text: text,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: ui.Color(0xFFF1F5F9),
          fontSize: 18,
          height: 1.25,
        ),
      ),
      position: Vector2(_leftW / 2, _panelY + _panelH / 2),
      priority: priority + 2,
    ));
  }

  Future<void> _addImageCentered(String imageRaw) async {
    final img = await _loadUiImage(imageRaw);
    if (img == null) {
      await add(TextComponent(
        text: 'Image not found:\n$imageRaw',
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(color: ui.Color(0xFFEF4444), fontSize: 12),
        ),
        position: Vector2(_leftW / 2, _panelY + _panelH / 2),
        priority: priority + 2,
      ));
      return;
    }

    const pad = 12.0;
    final maxW = _leftW - pad * 2;
    final maxH = _panelH - pad * 2;
    final aspect = img.width / img.height;

    double w = maxW;
    double h = w / aspect;
    if (h > maxH) {
      h = maxH;
      w = h * aspect;
    }

    await add(_RoundedImage(
      image: img,
      radius: 12,
      size: Vector2(w, h),
      anchor: Anchor.center,
      position: Vector2(_leftW / 2, _panelY + _panelH / 2),
      priority: priority + 2,
    ));
  }

  /// imagesound: Text trên cùng, ảnh ở giữa (bo góc), nút âm thanh ở đáy – tất cả trong cột trái.
  Future<void> _addImageSoundWithTitle({
    required String title,
    String? imageRaw,
    String? soundRaw,
  }) async {
    const pad = 12.0;

    // 1) Title ở trên (căn giữa)
    final titleComp = TextComponent(
      text: title,
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: ui.Color(0xFFF1F5F9),
          fontSize: 18,
          height: 1.25,
        ),
      ),
      position: Vector2(_leftW / 2, _panelY + pad),
      priority: priority + 2,
    );
    await add(titleComp);

    // Giả định chiều cao phần title ~ 28 (font 18 + line-height)
    const titleBlockH = 28.0 + pad; // text + spacing dưới

    // 2) Âm thanh ở đáy (căn giữa)
    const btnH = 32.0;
    const btnW = 140.0;
    const btnGapBottom = 12.0;
    final btnY = _panelY + _panelH - (btnGapBottom + btnH);

    if (soundRaw != null && soundRaw.isNotEmpty) {
      await add(_SmallButton(
        label: '🔊 Phát âm',
        onPressed: () => _playSoundRaw(soundRaw),
        position: Vector2((_leftW - btnW) / 2, btnY),
      )..size = Vector2(btnW, btnH));
    }

    // 3) Ảnh nằm giữa title và nút
    if (imageRaw == null || imageRaw.isEmpty) return;

    final img = await _loadUiImage(imageRaw);
    if (img == null) {
      await add(TextComponent(
        text: 'Image not found:\n$imageRaw',
        anchor: Anchor.topLeft,
        textRenderer: TextPaint(
          style: const TextStyle(color: ui.Color(0xFFEF4444), fontSize: 12),
        ),
        position: Vector2(12, _panelY + titleBlockH),
        priority: priority + 2,
      ));
      return;
    }

    final imageAreaTop = _panelY + titleBlockH + pad;
    final imageAreaBottom = btnY - pad; // chừa khoảng cho nút
    final imageAreaH = (imageAreaBottom - imageAreaTop).clamp(40.0, _panelH);

    final maxW = _leftW - pad * 2;
    final maxH = imageAreaH;
    final aspect = img.width / img.height;

    double w = maxW;
    double h = w / aspect;
    if (h > maxH) {
      h = maxH;
      w = h * aspect;
    }

    final centerY = imageAreaTop + imageAreaH / 2;

    await add(_RoundedImage(
      image: img,
      radius: 12,
      size: Vector2(w, h),
      anchor: Anchor.center,
      position: Vector2(_leftW / 2, centerY),
      priority: priority + 2,
    ));
  }

  Future<void> _addSoundButtonCentered(String raw) async {
    const btnW = 160.0;
    const btnH = 40.0;
    final pos = Vector2(_leftW / 2 - btnW / 2, _panelY + _panelH / 2 - btnH / 2);
    await add(_SmallButton(
      label: '🔊 Phát âm',
      onPressed: () => _playSoundRaw(raw),
      position: pos,
    )..size = Vector2(btnW, btnH));
  }
}

// ===== Rounded image component =====
class _RoundedImage extends PositionComponent {
  final ui.Image image;
  final double radius;

  _RoundedImage({
    required this.image,
    required this.radius,
    required super.size,
    required super.anchor,
    required super.position,
    required super.priority,
  });

  @override
  void render(ui.Canvas canvas) {
    final rect = ui.Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = ui.RRect.fromRectAndRadius(rect, ui.Radius.circular(radius));
    canvas.save();
    canvas.clipRRect(rrect);
    final src =
        ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    canvas.drawImageRect(image, src, rect, ui.Paint());
    canvas.restore();

    // viền nhẹ
    final border = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const ui.Color(0x22FFFFFF);
    canvas.drawRRect(rrect, border);
  }
}

// ===== Button & Answer item =====

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
    final r = ui.RRect.fromRectAndRadius(
      size.toRect(),
      const ui.Radius.circular(10),
    );
    final fill = ui.Paint()
      ..color = _down ? const ui.Color(0xFF2A3647) : const ui.Color(0xFF3B4A60);
    canvas.drawRRect(r, fill);

    final border = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const ui.Color(0x33FFFFFF);
    canvas.drawRRect(r, border);

    final tp = TextPaint(
      style: const TextStyle(color: ui.Color(0xFFF8FAFC), fontSize: 14),
    );
    tp.render(canvas, label, size / 2, anchor: Anchor.center);
  }

  @override
  void onTapDown(TapDownEvent e) => _down = true;
  @override
  void onTapCancel(TapCancelEvent e) => _down = false;
  @override
  void onTapUp(TapUpEvent e) {
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
      ..color = _down ? const ui.Color(0xFF2A3647) : const ui.Color(0xFF233042);
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
      ),
    );
    tp.render(canvas, label, Vector2(12, size.y / 2), anchor: Anchor.centerLeft);
  }

  @override
  void onTapDown(TapDownEvent e) => _down = true;
  @override
  void onTapCancel(TapCancelEvent e) => _down = false;
  @override
  void onTapUp(TapUpEvent e) {
    _down = false;
    onTap();
  }
}
