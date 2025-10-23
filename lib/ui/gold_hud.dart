import 'dart:ui' as ui;
import 'package:flutter/painting.dart' show TextStyle;

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show EdgeInsets;

class GoldHud extends PositionComponent {
  final EdgeInsets margin;
  final double iconSize;
  final double gap;
  final double paddingX;
  final double paddingY;
  final ui.Color bgColor;
  final ui.Color borderColor;
  final double borderWidth;
  final double radius;
  final double fontSize;

  int gold;

  late final SpriteComponent _icon;
  late final TextComponent _label;

  GoldHud({
    this.margin = const EdgeInsets.only(left: 8, top: 56),
    this.iconSize = 28,
    this.gap = 10,
    this.paddingX = 10,
    this.paddingY = 8,
    this.bgColor = const ui.Color(0xCC0F172A),
    this.borderColor = const ui.Color(0x55FFFFFF),
    this.borderWidth = 1,
    this.radius = 10,
    this.fontSize = 18,
    this.gold = 0,
    int priority = 100001,
  }) : super(priority: priority, anchor: Anchor.topLeft);

  void setGold(int value) {
    gold = value.clamp(0, 1 << 31);
    _label.text = gold.toString();
    _layoutChildren();
  }

  void addGold(int delta) => setGold(gold + delta);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final sprite = await Sprite.load('shop/gold.png');
    _icon = SpriteComponent(
      sprite: sprite,
      size: Vector2.all(iconSize),
      anchor: Anchor.topLeft,
      position: Vector2.zero(),
      priority: priority,
    );
    await add(_icon);

    _label = TextComponent(
      text: gold.toString(),
      anchor: Anchor.topLeft,
      position: Vector2.zero(),
      priority: priority,
      textRenderer: TextPaint(
        style: TextStyle(
          color: const ui.Color(0xFFE2E8F0),
          fontSize: fontSize,
        ),
      ),
    );
    await add(_label);

    _layoutChildren();
  }

  void _layoutChildren() {
    final approxCharW = fontSize * 0.6;
    final textW = _label.text.length * approxCharW;
    final contentW = iconSize + gap + textW;
    final contentH = (fontSize > iconSize ? fontSize : iconSize);

    final w = paddingX * 2 + contentW;
    final h = paddingY * 2 + contentH;

    size = Vector2(w, h);

    _icon.position = Vector2(
      margin.left + paddingX,
      margin.top + (h - iconSize) / 2,
    );
    _label.position = Vector2(
      margin.left + paddingX + iconSize + gap,
      margin.top + (h - fontSize) / 2 - 2,
    );
  }

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    final rect = ui.Rect.fromLTWH(
      margin.left.toDouble(),
      margin.top.toDouble(),
      size.x,
      size.y,
    );
    final rrect = ui.RRect.fromRectAndRadius(rect, ui.Radius.circular(radius));
    final bg = ui.Paint()..color = bgColor;
    canvas.drawRRect(rrect, bg);

    if (borderWidth > 0) {
      final border = ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = borderColor;
      canvas.drawRRect(rrect, border);
    }
  }
}