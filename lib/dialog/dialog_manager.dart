import 'dart:ui' show Rect, Size;
import 'package:flutter/foundation.dart';

// ===== Models =====
class Portrait {
  final String asset;
  final Rect? src;
  final Size size;
  const Portrait({required this.asset, this.src, this.size = const Size(48, 48)});
}

class DialogueChoice {
  final String text;
  final void Function()? onChoose;
  DialogueChoice(this.text, {this.onChoose});
}

class DialogueLine {
  final String text;
  final Portrait? speaker;
  final List<DialogueChoice> choices;
  const DialogueLine(this.text, {this.speaker, this.choices = const []});
}

// ===== Manager =====
class DialogManager {
  // Notifiers cho Overlay
  final ValueNotifier<String> currentText = ValueNotifier<String>('');
  final ValueNotifier<List<DialogueChoice>> currentChoices =
      ValueNotifier<List<DialogueChoice>>(<DialogueChoice>[]);
  final ValueNotifier<Portrait?> currentPortrait =
      ValueNotifier<Portrait?>(null);

  // Callbacks để Flame overlay mở/đóng
  void Function()? onRequestOpenOverlay;
  void Function()? onRequestCloseOverlay;

  // Trạng thái
  bool _isOpen = false;
  bool get isOpen => _isOpen;

  final List<DialogueLine> _script = [];
  int _idx = 0;

  /// Mở hội thoại tuyến tính.
  /// Nếu đang mở 1 phiên khác → **bỏ qua** (tránh chồng).
  void startLinear(List<DialogueLine> lines) {
    if (lines.isEmpty) return;
    if (_isOpen) {
      // đang mở → bỏ qua để không chồng hội thoại
      return;
    }
    _script
      ..clear()
      ..addAll(lines);
    _idx = 0;
    _isOpen = true;

    _apply(_script[_idx]);
    onRequestOpenOverlay?.call();
  }

  /// Next: nếu line hiện có choices ⇒ bỏ qua (đợi người chơi chọn)
  /// Nếu đã hết ⇒ close.
  void advance() {
    if (!_isOpen) return;
    if (currentChoices.value.isNotEmpty) {
      // đang chờ chọn, không next bằng tap
      return;
    }
    _idx++;
    if (_idx >= _script.length) {
      close();
    } else {
      _apply(_script[_idx]);
    }
  }

  /// Chọn 1 phương án. Nếu có callback thì gọi, sau đó next.
  void choose(int i) {
    if (!_isOpen) return;
    final cs = currentChoices.value;
    if (i < 0 || i >= cs.length) return;
    cs[i].onChoose?.call();
    // Sau khi chọn → clear choices và next
    currentChoices.value = const [];
    advance();
  }

  /// Đóng hội thoại (reset trạng thái + đóng overlay)
  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    _script.clear();
    _idx = 0;
    currentText.value = '';
    currentChoices.value = const [];
    currentPortrait.value = null;
    onRequestCloseOverlay?.call();
  }

  void _apply(DialogueLine line) {
    currentText.value = line.text;
    currentPortrait.value = line.speaker;
    currentChoices.value = List.unmodifiable(line.choices);
  }
}
