import 'dart:ui' as ui;
import 'package:flutter/painting.dart' show TextStyle;

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show EdgeInsets;

class GoldHud extends PositionComponent {
  final EdgeInsets margin;
  final double iconSize;
  final double gap;

  int gold;

  late final SpriteComponent _icon;
  late final TextComponent _label;

  GoldHud({
    this.margin = const EdgeInsets.only(left: 8, top: 56),
    this.iconSize = 16,
    this.gap = 6,
    this.gold = 0,
    int priority = 100001,
  }) : super(priority: priority, anchor: Anchor.topLeft);

  void setGold(int value) {
    gold = value.clamp(0, 1 << 31);
    _label.text = gold.toString();
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
      position: Vector2(margin.left.toDouble(), margin.top.toDouble()),
      priority: priority,
    );
    await add(_icon);

    _label = TextComponent(
      text: gold.toString(),
      anchor: Anchor.topLeft,
      position: Vector2(
        margin.left.toDouble() + iconSize + gap,
        margin.top.toDouble() - 2,
      ),
      priority: priority,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: ui.Color(0xFFE2E8F0),
          fontSize: 12,
        ),
      ),
    );
    await add(_label);

    size = Vector2(iconSize + gap + (_label.text.length * 8.0), iconSize);
    position = Vector2.zero();
  }
}
