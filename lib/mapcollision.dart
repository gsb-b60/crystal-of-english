// lib/mapcollision.dart
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class MapLoader extends PositionComponent {
  final String mapPath;
  final String collisionLayerName;
  late TiledComponent map;

  MapLoader({
    required this.mapPath,
    required this.collisionLayerName,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    map = await TiledComponent.load(
      mapPath,
      Vector2.all(16),
      prefix: 'assets/maps/',
    );
    add(map);

    // Load layer collision
    final collisionLayer = map.tileMap.getLayer<ObjectGroup>(collisionLayerName);
    if (collisionLayer == null) return;

    for (final obj in collisionLayer.objects) {
      if (obj.isPolygon) {
        final points = obj.polygon!.map((p) => Vector2(p.x, p.y)).toList();
        add(PolygonHitbox(points, position: Vector2(obj.x, obj.y))
          ..collisionType = CollisionType.passive
          ..renderShape = true); // debug
      } else {
        add(RectangleHitbox(
          position: Vector2(obj.x, obj.y),
          size: Vector2(obj.width, obj.height),
        )
          ..collisionType = CollisionType.passive
          ..renderShape = true);
      }
    }
  }
}
