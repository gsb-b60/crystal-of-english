import 'package:flutter/material.dart';
import '../audio/audio_manager.dart';
import 'inventory_panel.dart';
                    if (open)
                      ConstrainedBox(
                        // limit width and height so panel won't overflow; allow scrolling when needed
                        constraints: BoxConstraints(
                          maxWidth: 280,
                          maxHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: Material(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          elevation: 4,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(8),
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

                                  // BGM toggle + slider
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

                                  // SFX toggle + slider
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
                                  // Go to main menu and Pause buttons
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() => open = false);
                                          widget.onGoToMain?.call();
                                        },
                                        icon: const Icon(Icons.home),
                                        label: const Text('Main Menu'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() => open = false);
                                          widget.onPause?.call();
                                        },
                                        icon: const Icon(Icons.pause),
                                        label: const Text('Pause'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Settings panel
                    if (open)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Material(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          elevation: 4,
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

                                // BGM toggle + slider
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

                                // SFX toggle + slider
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
                                // Go to main menu button
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // close panel first
                                        setState(() => open = false);
                                        // call parent callback if provided
                                        widget.onGoToMain?.call();
                                      },
                                      icon: const Icon(Icons.home),
                                      label: const Text('Main Menu'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // close settings panel
                                        setState(() => open = false);
                                        // delegate to parent to open pause menu
                                        widget.onPause?.call();
                                      },
                                      icon: const Icon(Icons.pause),
                                      label: const Text('Pause'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Inventory panel
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
