import 'package:flutter/material.dart';
import 'package:mygame/main.dart';
import 'package:mygame/components/Menu/save_load/save_load_screen.dart';
import '../audio/audio_manager.dart';
import 'inventory_panel.dart';
import '../state/inventory.dart';
// player_profile import removed (not used here)

class SettingsOverlay extends StatefulWidget {
  static const id = 'settings_overlay';

  final AudioManager audio;
  final void Function(GameItem item)? onUseItem;
  final MyGame? game;

  const SettingsOverlay({super.key, required this.audio, this.onUseItem, this.game});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  bool open = false;
  bool invOpen = false;

  late bool _bgmEnabled;
  late bool _sfxEnabled;
  late double _bgmVol;
  late double _sfxVol;

  @override
  void initState() {
    super.initState();
    _bgmEnabled = widget.audio.bgmEnabled;
    _sfxEnabled = widget.audio.sfxEnabled;
    _bgmVol = widget.audio.bgmVolume;
    _sfxVol = widget.audio.sfxVolume;
  }

  // NOTE: button behaviors implemented inline where used.

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Stack(
          children: [

            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  // ensure stack doesn't take full width
                  width: 400,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // icons column fixed at right edge
                      Positioned(
                        right: 8,
                        top: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              color: Colors.black.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => setState(() => open = !open),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Material(
                              color: Colors.black.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => setState(() => invOpen = !invOpen),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.inventory_2,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // sliding panel sits to the left of the icons
                      // icons column width ~56, so panel right = iconsWidth + spacing
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        right: (open) ? 56 + 8 : 8,
                        top: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          // animate width only (avoid animating between finite and unbounded height)
                          width: open ? 320 : 0,
                          child: ConstrainedBox(
                            // match max width to the animated width so constraints are always finite
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: Material(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(12),
                              elevation: 4,
                              child: Opacity(
                                opacity: open ? 1.0 : 0.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.tune, size: 18),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Settings',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.close, size: 18),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => setState(() => open = false),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Music (BGM)
                                      Row(
                                        children: [
                                          Switch(
                                            value: _bgmEnabled,
                                            onChanged: (v) {
                                              setState(() => _bgmEnabled = v);
                                              widget.audio.setBgmEnabled(v);
                                            },
                                          ),
                                          const SizedBox(width: 6),
                                          const Text('Music'),
                                        ],
                                      ),
                                      Slider(
                                        value: _bgmVol,
                                        min: 0,
                                        max: 1,
                                        onChanged: (val) {
                                          setState(() => _bgmVol = val);
                                          widget.audio.setBgmVolume(val);
                                        },
                                      ),
                                      const SizedBox(height: 4),

                                      // Sound Effects (SFX)
                                      Row(
                                        children: [
                                          Switch(
                                            value: _sfxEnabled,
                                            onChanged: (v) {
                                              setState(() => _sfxEnabled = v);
                                              widget.audio.setSfxEnabled(v);
                                            },
                                          ),
                                          const SizedBox(width: 6),
                                          const Text('SFX'),
                                        ],
                                      ),
                                      Slider(
                                        value: _sfxVol,
                                        min: 0,
                                        max: 1,
                                        onChanged: (val) {
                                          setState(() => _sfxVol = val);
                                          widget.audio.setSfxVolume(val);
                                        },
                                      ),
                                      const SizedBox(height: 8),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                // Toggle pause/resume including audio
                                                final g = widget.game;
                                                if (g != null) {
                                                  await g.togglePause();
                                                  if (mounted) setState(() {});
                                                }
                                              },
                                              icon: Icon((widget.game?.isPaused ?? false)
                                                  ? Icons.play_arrow
                                                  : Icons.pause),
                                              label: Text((widget.game?.isPaused ?? false)
                                                  ? 'Continue'
                                                  : 'Pause'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                // Open Save/Load screen to allow selecting slot to save
                                                final g = widget.game;
                                                // remove settings overlay while navigating so it doesn't overlap
                                                if (g != null && g.overlays.isActive(SettingsOverlay.id)) {
                                                  g.overlays.remove(SettingsOverlay.id);
                                                }
                                                await Navigator.of(context).push(MaterialPageRoute(
                                                  builder: (c) => SaveLoadScreen(game: g),
                                                ));
                                                // when returning, re-add settings overlay if game exists
                                                if (g != null && !g.overlays.isActive(SettingsOverlay.id)) {
                                                  g.overlays.add(SettingsOverlay.id);
                                                }
                                              },
                                              icon: const Icon(Icons.save),
                                              label: const Text('Save'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                final g = widget.game;
                                                if (g != null) {
                                                  // Home: return to main menu with smooth BGM fade-in
                                                  if (g.overlays.isActive(SettingsOverlay.id)) {
                                                    g.overlays.remove(SettingsOverlay.id);
                                                  }
                                                  await g.pauseGame();
                                                  if (!g.overlays.isActive('MainMenu')) {
                                                    g.overlays.add('MainMenu');
                                                  }

                                                  // Restart menu music from the beginning (no fade required)
                                                  try {
                                                    await widget.audio.playBgm('audio/bgm_overworld.mp3', volume: widget.audio.bgmVolume);
                                                  } catch (_) {}
                                                }
                                              },
                                              icon: const Icon(Icons.home),
                                              label: const Text('Home'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


            if (invOpen)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: InventoryPanel(
                    onClose: () => setState(() => invOpen = false),
                    onUseItem: widget.onUseItem,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
