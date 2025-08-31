import 'dart:math';
import 'dart:ui' show Rect, Size;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../dialog/dialog_manager.dart';
import 'speechbubble.dart';
import 'interact_badge.dart';
import '../main.dart';

Vector2 tileCenter(int col, int row, {double tileSize = 16}) =>
    Vector2((col + 0.5) * tileSize, (row + 0.5) * tileSize);

/// Cấu hình animation từ sprite sheet (sequenced).
class NpcAnimConfig {
  final Vector2 frameSize;   // kích thước 1 frame (vd 64x64)
  final int amount;          // tổng số frame
  final double stepTime;     // thời gian mỗi frame (giây)
  final int amountPerRow;    // frame mỗi hàng (0 => = amount)
  final Vector2 offset;      // offset frame đầu trong sheet
  NpcAnimConfig({
    required this.frameSize,
    required this.amount,
    this.stepTime = 0.12,
    this.amountPerRow = 0,
    Vector2? offset,                       // tránh const default
  }) : offset = offset ?? Vector2.zero();
}

/// NPC có:
/// - Idle chatter: bong bóng tự nói theo chu kỳ (tách cấu hình riêng)
/// - Interact dialogue: mở DialogOverlay khi người chơi nhấn/tap (badge vô hình)
class Npc extends SpriteComponent with HasGameRef<MyGame> {
  final DialogManager manager;

  // ===== SPRITE / ANIM =====
  final String spriteAsset;
  final Vector2 srcPosition;
  final Vector2 srcSize;
  final NpcAnimConfig? anim;
  final int zPriority;

  // ===== AVATAR ở DialogOverlay =====
  final String? avatarAsset;
  final Vector2? avatarSrcPosition;
  final Vector2? avatarSrcSize;
  final Size avatarDisplaySize;

  // ===== INTERACT DIALOGUE (khi người chơi nhấn) =====
  final List<String> interactLines;      // thoại khi tương tác
  int _interactIdx = 0;

  // ===== IDLE CHATTER (tự thoại lặp lại) =====
  bool enableIdleChatter;                // bật/tắt tự thoại
  final List<String> idleLines;          // câu tự thoại
  int _idleIdx = 0;
  final double idleSpeakEvery;           // chu kỳ nói
  final double idleShowFor;              // thời gian hiện bong bóng
  final bool idleOnlyNearPlayer;         // chỉ nói khi người chơi ở gần
  final double idleTalkRadius;           // bán kính kiểm tra
  final double idleBubbleOffsetY;        // offset Y bong bóng
  TimerComponent? _idleLoop;
  final _rnd = Random();

  // ===== INTERACT BADGE (vùng tap vô hình) =====
  final double interactRadius;
  final double interactGapToCenter;
  InteractBadge? _badge;

  // ===== STATE =====
  SpeechBubble? _bubble;
  SpriteAnimationComponent? _animComp;

  Npc({
    required Vector2 position,
    required this.manager,

    // sprite/anim
    this.spriteAsset = 'player.png',
    Vector2? srcPosition,
    Vector2? srcSize,
    this.anim,
    this.zPriority = 20,

    // avatar
    this.avatarAsset,
    this.avatarSrcPosition,
    this.avatarSrcSize,
    this.avatarDisplaySize = const Size(48, 48),

    // interact dialogue
    required this.interactLines,

    // idle chatter
    this.enableIdleChatter = true,
    required this.idleLines,
    this.idleSpeakEvery = 4,
    this.idleShowFor = 2,
    this.idleOnlyNearPlayer = false,
    this.idleTalkRadius = 160,
    this.idleBubbleOffsetY = 0,

    // interact region
    this.interactRadius = 56,
    this.interactGapToCenter = 0,

    // hiển thị
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

    // ===== sprite / anim =====
    final img = await gameRef.images.load(spriteAsset);
    if (anim == null) {
      sprite = Sprite(img, srcPosition: srcPosition, srcSize: srcSize);
    } else {
      final cfg = anim!;
      final data = SpriteAnimationData.sequenced(
        amount: cfg.amount,
        stepTime: cfg.stepTime,
        textureSize: cfg.frameSize,
        amountPerRow: cfg.amountPerRow == 0 ? cfg.amount : cfg.amountPerRow,
        texturePosition: cfg.offset,
      );
      final animation = SpriteAnimation.fromFrameData(img, data);
      _animComp = SpriteAnimationComponent(
        animation: animation,
        size: size,
        anchor: Anchor.center,
        priority: zPriority,
      );
      await add(_animComp!);
      sprite = null;
    }

    // ===== badge tương tác vô hình =====
    _badge = InteractBadge(
      target: this,
      radius: interactRadius,
      gapToCenter: interactGapToCenter,
      onPressed: _openInteractDialogue,
    );
    parent?.add(_badge!);

    // ===== idle chatter loop (nếu bật) =====
    if (enableIdleChatter && idleLines.isNotEmpty) {
      final jitter = _rnd.nextDouble() * 1.5;
      _idleLoop = TimerComponent(
        period: idleSpeakEvery,
        repeat: true,
        autoStart: false,
        onTick: _idleSpeakOnce,
      );
      add(_idleLoop!);
      add(TimerComponent(
        period: jitter,
        onTick: () {
          _idleSpeakOnce();
          _idleLoop?.timer.start();
        },
        removeOnFinish: true,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_badge != null && !_badge!.isMounted && parent != null) {
      parent!.add(_badge!);
    }
  }

  // ========= PUBLIC API để điều khiển Idle Chatter theo ý bạn =========
  void startIdleChatter() {
    enableIdleChatter = true;
    _idleLoop?.timer.start();
  }

  void stopIdleChatter() {
    enableIdleChatter = false;
    _idleLoop?.timer.stop();
    _removeBubble();
  }

  void setIdleLines(List<String> lines, {bool resetIndex = true}) {
    idleLines
      ..clear()
      ..addAll(lines);
    if (resetIndex) _idleIdx = 0;
  }

  void setInteractLines(List<String> lines, {bool resetIndex = true}) {
    interactLines
      ..clear()
      ..addAll(lines);
    if (resetIndex) _interactIdx = 0;
  }

  // ========= Interact Dialogue =========
  void _openInteractDialogue() {
    if (interactLines.isEmpty) return;
    if (manager.isOpen) return;          // không mở chồng

    // dọn bubble idle nếu đang hiện
    _removeBubble();

    // chọn asset & src cho avatar
    final avatarAssetPath = avatarAsset ?? spriteAsset;
    Rect avatarSrc;
    if (avatarSrcPosition != null && avatarSrcSize != null) {
      avatarSrc = Rect.fromLTWH(
        avatarSrcPosition!.x, avatarSrcPosition!.y,
        avatarSrcSize!.x, avatarSrcSize!.y,
      );
    } else if (anim != null) {
      final a = anim!;
      avatarSrc = Rect.fromLTWH(a.offset.x, a.offset.y, a.frameSize.x, a.frameSize.y);
    } else {
      avatarSrc = Rect.fromLTWH(srcPosition.x, srcPosition.y, srcSize.x, srcSize.y);
    }

    // chuẩn bị kịch bản: bắt đầu từ _interactIdx (tuỳ thích)
    final script = <DialogueLine>[];
    for (int i = 0; i < interactLines.length; i++) {
      final idx = (_interactIdx + i) % interactLines.length;
      script.add(
        DialogueLine(
          interactLines[idx],
          speaker: Portrait(
            asset: avatarAssetPath,
            src: avatarSrc,
            size: avatarDisplaySize,
          ),
        ),
      );
    }
    // lần sau sẽ bắt đầu tiếp câu kế
    _interactIdx = (_interactIdx + 1) % (interactLines.isEmpty ? 1 : interactLines.length);

    manager.startLinear(script);
  }

  // ========= Idle Chatter =========
  Future<void> _idleSpeakOnce() async {
    if (!enableIdleChatter) return;
    if (idleLines.isEmpty) return;

    // nếu đang hội thoại overlay → không tự chat ngoài
    if (manager.isOpen) return;

    // nếu bật chỉ nói khi gần player
    if (idleOnlyNearPlayer) {
      final p = gameRef.player;
      if (p.position.distanceTo(position) > idleTalkRadius) return;
    }

    final text = idleLines[_idleIdx % idleLines.length];
    _idleIdx++;

    _removeBubble();

    final b = SpeechBubble(
      text: text,
      target: this,
      maxWidth: 160,
      padding: 6,
      gapToHead: idleBubbleOffsetY,
    );
    if (parent != null) {
      await parent!.add(b);
      _bubble = b;
    }

    add(TimerComponent(
      period: idleShowFor,
      onTick: _removeBubble,
      removeOnFinish: true,
    ));
  }

  void _removeBubble() {
    _bubble?.removeFromParent();
    _bubble = null;
  }

  // ========= tiện ích =========
  void teleportTo(Vector2 p) => position = p;
  void teleportToTile(int col, int row, {double tileSize = 16}) =>
      position = tileCenter(col, row, tileSize: tileSize);

  @override
  void onRemove() {
    _removeBubble();
    _badge?.removeFromParent();
    _badge = null;
    super.onRemove();
  }
}
