import 'package:flutter/material.dart';
import 'dialog_manager.dart';
import '../ui/sprite_slice.dart';

class DialogOverlay extends StatelessWidget {
  static const id = 'dialog';
  final DialogManager manager;
  const DialogOverlay({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: manager.advance, // nhấn bất kỳ để next (nếu không có choices)
      child: Stack(
        children: [
          // Avatar góc trái phía trên hộp thoại
          Positioned(
            left: 12, bottom: 84,
            child: ValueListenableBuilder<Portrait?>(
              valueListenable: manager.currentPortrait,
              builder: (context, p, _) {
                if (p == null) return const SizedBox.shrink();
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: SpriteSlice(
                    asset: p.asset,
                    source: p.src ?? const Rect.fromLTWH(0, 0, 48, 48),
                    displaySize: p.size,
                  ),
                );
              },
            ),
          ),

          // Hộp thoại + lựa chọn
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // hộp thoại
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ValueListenableBuilder<String>(
                      valueListenable: manager.currentText,
                      builder: (context, text, _) => Text(
                        text,
                        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.3),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),

                  // lựa chọn (nếu có)
                  const SizedBox(height: 8),
                  ValueListenableBuilder<List<DialogueChoice>>(
                    valueListenable: manager.currentChoices,
                    builder: (context, choices, _) {
                      if (choices.isEmpty) {
                        return const SizedBox(
                          height: 18,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('Nhấn để tiếp tục',
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < choices.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: Colors.black, width: 1),
                                  ),
                                ),
                                onPressed: () => manager.choose(i),
                                child: Text(choices[i].text),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
