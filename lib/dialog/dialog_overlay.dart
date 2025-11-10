import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'dialog_manager.dart';
import '../ui/sprite_slice.dart';

class DialogOverlay extends StatefulWidget {
  static const id = 'dialog';
  final DialogManager manager;
  const DialogOverlay({super.key, required this.manager});

  @override
  State<DialogOverlay> createState() => _DialogOverlayState();
}

class _DialogOverlayState extends State<DialogOverlay> {
  @override
  Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size;
  const panelFactor = 0.5; // dialog occupies half the screen height
  final panelH = size.height * panelFactor;
    final manager = widget.manager;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (manager.currentChoices.value.isEmpty) {
          manager.advance();
        }
      },
      child: Stack(
        children: [
          // Avatar trái
          ValueListenableBuilder<Portrait?>(
            valueListenable: manager.currentPortrait,
            builder: (context, p, _) {
              if (p == null) return const SizedBox.shrink();
              return Positioned(
                left: 12,
                bottom: panelH + 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SpriteSlice(
                    asset: p.asset,
                    source: p.src ?? const Rect.fromLTWH(0, 0, 48, 48),
                    displaySize: p.size,
                  ),
                ),
              );
            },
          ),

          // Avatar phải (nếu có)
          ValueListenableBuilder<Portrait?>(
            valueListenable: manager.currentRightPortrait,
            builder: (context, p, _) {
              if (p == null) return const SizedBox.shrink();
              return Positioned(
                right: 12,
                bottom: panelH + 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SpriteSlice(
                    asset: p.asset,
                    source: p.src ?? const Rect.fromLTWH(0, 0, 48, 48),
                    displaySize: p.size,
                  ),
                ),
              );
            },
          ),

          // Panel dưới
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                width: size.width,
                height: panelH,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.78),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LEFT: question area (half width)
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: ValueListenableBuilder<String?>(
                            valueListenable: manager.currentType,
                            builder: (context, type, _) {
                              final text = manager.currentText.value;
                              final imageRaw = manager.currentImage.value;
                              final soundRaw = manager.currentSound.value;
                              // default to text if no explicit type
                              final t = (type ?? 'text').toLowerCase();
                              if (t == 'image') {
                                if (imageRaw == null || imageRaw.isEmpty) {
                                  return Center(child: Text('Image not found', style: TextStyle(color: Colors.white)));
                                }
                                return Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      imageRaw,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                );
                              } else if (t == 'sound') {
                                return Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (soundRaw != null && soundRaw.isNotEmpty) FlameAudio.play(soundRaw);
                                    },
                                    icon: const Icon(Icons.volume_up),
                                    label: const Text('Play'),
                                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  ),
                                );
                              } else if (t == 'imagesound' || t == 'image_sound') {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (soundRaw != null && soundRaw.isNotEmpty)
                                      ElevatedButton.icon(
                                        onPressed: () => FlameAudio.play(soundRaw),
                                        icon: const Icon(Icons.volume_up),
                                        label: const Text('Play'),
                                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                      ),
                                    const SizedBox(height: 8),
                                    if (imageRaw != null && imageRaw.isNotEmpty)
                                      Expanded(
                                        child: Center(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.asset(imageRaw, fit: BoxFit.contain, width: double.infinity, height: double.infinity),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              } else {
                                // text default: center both horizontally and vertically
                                return Center(
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Text(
                                      text,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'MyFont',
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // RIGHT: answers area (half width)
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 218, 218, 218).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: ValueListenableBuilder<List<DialogueChoice>>(
                            valueListenable: manager.currentChoices,
                            builder: (context, choices, _) {
                              if (choices.isEmpty) return const SizedBox.shrink();
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: choices.map((c) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => manager.choose(choices.indexOf(c)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                        ),
                                        child: Text(
                                          c.text,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 16, height: 1.2),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _ChoiceButton({required this.label, required this.onPressed});

  @override
  State<_ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<_ChoiceButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _down ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) {
          setState(() => _down = false);
          widget.onPressed();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'MyFont', 
                color: Colors.black,
                fontSize: 15,
                height: 1.25,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
