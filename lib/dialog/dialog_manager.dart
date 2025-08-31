import 'package:flutter/material.dart';

/// Ảnh đại diện NPC hiển thị trên overlay.
class Portrait {
  final String asset;     // ví dụ: 'assets/player.png'
  final Rect? src;        // vùng cắt trong spritesheet; null = full ảnh
  final Size size;        // kích thước hiển thị
  const Portrait({
    required this.asset,
    this.src,
    this.size = const Size(48, 48),
  });
}

/// Một câu thoại tuyến tính.
class DialogueLine {
  final String text;
  final Portrait? speaker;
  const DialogueLine(this.text, {this.speaker});
}

/// Một lựa chọn tại node hội thoại tương tác.
class DialogueChoice {
  final String text;
  final DialogueNode? next;
  final VoidCallback? onSelect; // callback phụ (mở shop, set quest…)
  const DialogueChoice({required this.text, this.next, this.onSelect});
}

/// Node hội thoại (dùng cho hội thoại tương tác/tree).
class DialogueNode {
  final String text;
  final Portrait? speaker;
  final List<DialogueChoice> choices; // nếu không rỗng => đang chờ chọn
  final DialogueNode? next;           // nếu rỗng => tuyến tính
  const DialogueNode({
    required this.text,
    this.speaker,
    this.choices = const [],
    this.next,
  });
}

/// Quản lý trạng thái hội thoại + API dùng từ game/NPC.
class DialogManager {
  // --- trạng thái public để UI bind ---
  final ValueNotifier<bool> isOpen = ValueNotifier<bool>(false);
  final ValueNotifier<String> currentText = ValueNotifier<String>('');
  final ValueNotifier<Portrait?> currentPortrait = ValueNotifier<Portrait?>(null);
  final ValueNotifier<List<DialogueChoice>> currentChoices =
      ValueNotifier<List<DialogueChoice>>(<DialogueChoice>[]);

  // --- tuyến tính ---
  List<DialogueLine> _lines = <DialogueLine>[];
  int _idx = 0;

  // --- tree ---
  DialogueNode? _cursor;

  // --- hook mở/đóng overlay (để main.dart nối với overlays của Flame) ---
  void Function()? onRequestOpenOverlay;
  void Function()? onRequestCloseOverlay;

  // ===== API =====

  /// Mở hội thoại tuyến tính.
  void startLinear(List<DialogueLine> lines) {
    if (lines.isEmpty) return;
    _lines = lines;
    _idx = 0;
    _cursor = null;
    _applyLinear();
    _open();
  }

  /// Mở hội thoại dạng cây (có lựa chọn).
  void startTree(DialogueNode root) {
    _cursor = root;
    _lines = [];
    _idx = 0;
    _applyNode(root);
    _open();
  }

  /// Nhấn để qua câu (nếu không có lựa chọn); hết thì đóng.
  void advance() {
    if (currentChoices.value.isNotEmpty) return; // đang chờ chọn
    if (_cursor != null) {
      // chế độ tree
      final node = _cursor!;
      if (node.choices.isNotEmpty) return;
      if (node.next != null) {
        _cursor = node.next;
        _applyNode(_cursor!);
      } else {
        close();
      }
      return;
    }
    // chế độ tuyến tính
    if (_idx + 1 < _lines.length) {
      _idx++;
      _applyLinear();
    } else {
      close();
    }
  }

  /// Chọn một lựa chọn ở node hiện tại (chế độ tree).
  void choose(int index) {
    if (_cursor == null) return;
    final choices = _cursor!.choices;
    if (index < 0 || index >= choices.length) return;
    final c = choices[index];
    c.onSelect?.call();
    if (c.next != null) {
      _cursor = c.next;
      _applyNode(_cursor!);
    } else {
      close();
    }
  }

  /// Đóng hội thoại.
  void close() {
    isOpen.value = false;
    currentText.value = '';
    currentPortrait.value = null;
    currentChoices.value = const [];
    _lines = [];
    _idx = 0;
    _cursor = null;
    onRequestCloseOverlay?.call();
  }

  // ===== helpers =====

  void _open() {
    isOpen.value = true;
    onRequestOpenOverlay?.call();
  }

  void _applyLinear() {
    final line = _lines[_idx];
    currentText.value = line.text;
    if (line.speaker != null) currentPortrait.value = line.speaker;
    currentChoices.value = const [];
  }

  void _applyNode(DialogueNode node) {
    currentText.value = node.text;
    if (node.speaker != null) currentPortrait.value = node.speaker;
    currentChoices.value = node.choices;
  }
}
