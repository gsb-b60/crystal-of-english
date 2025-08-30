import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Collision {
  final TiledComponent map;
  final Component parent;

  Collision({required this.map, required this.parent});

  Future<void> loadLayer(String layerName) async {
    final collisionLayer = map.tileMap.getLayer<ObjectGroup>(layerName);
    if (collisionLayer == null) {
      print('Không tìm thấy layer: $layerName');
      return;
    }

    print('layer $layerName, objects: ${collisionLayer.objects.length}');
    for (final obj in collisionLayer.objects) {
      print('Object: ${obj.isPolygon ? "Polygon" : "Rectangle"}, x: ${obj.x}, y: ${obj.y}, vertices: ${obj.polygon}');
      if (obj.isPolygon) {
        final vertices = obj.polygon.map((point) => Vector2(point.x, point.y)).toList();
        final hitboxComponent = HitboxComponent(
          position: Vector2(obj.x, obj.y),
          vertices: vertices,
        );
        await parent.add(hitboxComponent);
      } else if (obj.width > 0 && obj.height > 0) {
        final hitboxComponent = HitboxComponent(
          position: Vector2(obj.x, obj.y),
          size: Vector2(obj.width, obj.height),
        );
        await parent.add(hitboxComponent);
      }
    }
  }
}

class HitboxComponent extends PositionComponent with CollisionCallbacks {
  HitboxComponent({
    required Vector2 position,
    Vector2? size,
    List<Vector2>? vertices,
  }) {
    this.position = position;

    if (vertices != null) {
      add(PolygonHitbox(vertices)
        ..collisionType = CollisionType.passive
        ..debugMode = true);
    } else if (size != null) {
      add(RectangleHitbox(size: size)
        ..collisionType = CollisionType.passive
        ..debugMode = true);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    print('HitboxComponent collided with ${other.runtimeType} at $intersectionPoints');
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    print('HitboxComponent collision ended with ${other.runtimeType}');
  }
}