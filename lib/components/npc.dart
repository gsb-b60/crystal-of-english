import 'dart:math';
import 'dart:ui' show Rect, Size;            // <-- để dùng Rect, Size
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import '../dialog/dialog_manager.dart';
import 'speechbubble.dart';
import 'interact_badge.dart';
import '../main.dart';                       // <-- để MyGame có mặt cho HasGameRef

Vector2 tileCenter(int col, int row, {double tileSize = 16}) =>
    Vector2((col + 0.5) * tileSize, (row + 0.5) * tileSize);

class Npc extends SpriteComponent
    with HasGameRef<MyGame> {                // <-- cần HasGameRef để dùng gameRef
  final DialogManager manager;        // dialog manager (BẮT BUỘC truyền)
  final List<String> lines;           // thoại tuyến tính mặc định

  // tự thoại
  final double speakEvery;
  final double showFor;
  final bool onlyTalkNearPlayer;
  final double talkRadius;

  // hiển thị
  final String spriteAsset;
  final Vector2 srcPosition;
  final Vector2 srcSize;
  final int zPriority;

  // bong bóng
  final double bubbleOffsetY;

  // badge tương tác
  final double interactRadius;
  final String interactLabel;

  int _idx = 0;
  SpeechBubble? _bubble;
  InteractBadge? _badge;
  final _rnd = Random();

  Npc({
    required Vector2 position,
    required this.manager,                   // <-- bắt buộc
    required this.lines,
    this.speakEvery = 4,
    this.showFor = 2,
    this.onlyTalkNearPlayer = false,
    this.talkRadius = 160,
    this.spriteAsset = 'player.png',
    Vector2? srcPosition,
    Vector2? srcSize,
    this.zPriority = 20,
    this.bubbleOffsetY = 0,
    this.interactRadius = 56,
    this.interactLabel = 'Nói',
    Vector2? size,
  })  : srcPosition = srcPosition ?? Vector2(0, 0),
        srcSize = srcSize ?? Vector2(80, 80),
        super(
          position: position,
          size: size ?? Vector2(80, 80),
          anchor: Anchor.center,
          priority: zPriority,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final img = await gameRef.images.load(spriteAsset);
    sprite = Sprite(img, srcPosition: srcPosition, srcSize: srcSize);

    // badge tại tâm NPC (add vào world/parent của NPC)
    _badge = InteractBadge(
      target: this,
      radius: interactRadius,
      gapToCenter: 0,
      label: interactLabel,
      onPressed: _openDialogLinear,
    );
    parent?.add(_badge!);

    // tự thoại (lệch nhịp để các NPC không đồng thanh)
    final jitter = _rnd.nextDouble() * 1.5;
    final loop = TimerComponent(
      period: speakEvery,
      repeat: true,
      onTick: _speakOnce,
      autoStart: false,
    );
    add(loop);
    add(TimerComponent(
      period: jitter,
      onTick: () {
        _speakOnce();
        loop.timer.start();
      },
      removeOnFinish: true,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_badge != null && !_badge!.isMounted && parent != null) {
      parent!.add(_badge!);
    }
  }

  // mở hội thoại tuyến tính bằng DialogManager
  void _openDialogLinear() {
    if (lines.isEmpty) return;
    manager.startLinear(
      lines.map((t) => DialogueLine(
        t,
        speaker: Portrait(
          asset: spriteAsset,
          src: Rect.fromLTWH(
            srcPosition.x, srcPosition.y, srcSize.x, srcSize.y,
          ),
          size: const Size(48, 48),
        ),
      )).toList(),
    );
  }

  Future<void> _speakOnce() async {
    if (lines.isEmpty) return;

    if (onlyTalkNearPlayer) {
      final p = gameRef.player;                         // <-- dùng gameRef.player
      if (p.position.distanceTo(position) > talkRadius) return;
    }

    final text = lines[_idx % lines.length];
    _idx++;

    _bubble?.removeFromParent();
    _bubble = null;

    final b = SpeechBubble(
      text: text,
      target: this,
      maxWidth: 160,
      padding: 6,
      gapToHead: bubbleOffsetY,
    );
    if (parent != null) {
      await parent!.add(b);
      _bubble = b;
    }

    add(TimerComponent(
      period: showFor,
      onTick: () {
        _bubble?.removeFromParent();
        _bubble = null;
      },
      removeOnFinish: true,
    ));
  }

  void teleportTo(Vector2 p) => position = p;
  void teleportToTile(int col, int row, {double tileSize = 16}) =>
      position = tileCenter(col, row, tileSize: tileSize);

  @override
  void onRemove() {
    _bubble?.removeFromParent();
    _badge?.removeFromParent();
    _bubble = null;
    _badge = null;
    super.onRemove();
  }
}
