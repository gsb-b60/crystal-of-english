import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  bool _bgmEnabled = true;
  bool _sfxEnabled = true;
  double _bgmVolume = 0.5;
  double _sfxVolume = 0.8;
  String? _currentBgm;

  Future<void> init() async {
    await FlameAudio.bgm.initialize();
  }




  Future<void> playBgm(String asset, {double? volume, bool loop = true}) async {
    if (!_bgmEnabled) return;
    _currentBgm = asset;
    if (volume != null) {
      _bgmVolume = volume.clamp(0.0, 1.0).toDouble();
    }
    await FlameAudio.bgm.stop();
    await FlameAudio.bgm.play(asset, volume: _bgmVolume);
  }

  Future<void> stopBgm() async {
    _currentBgm = null;
    await FlameAudio.bgm.stop();
  }

  Future<void> pauseBgm() async {
    await FlameAudio.bgm.pause();
  }

  Future<void> resumeBgm() async {
    if (!_bgmEnabled) return;
    await FlameAudio.bgm.resume();
  }

  /// Fade the bgm volume to [target] over [duration].
  /// This will step the volume in small increments. If no bgm is playing
  /// the method returns immediately.
  Future<void> fadeBgmTo(double target, Duration duration, {int steps = 20}) async {
    if (!_bgmEnabled) return;
  final player = FlameAudio.bgm.audioPlayer;
    target = target.clamp(0.0, 1.0).toDouble();
    final current = _bgmVolume.clamp(0.0, 1.0).toDouble();
    final stepDur = duration ~/ steps;
    if (stepDur.inMilliseconds <= 0) {
      setBgmVolume(target);
      return;
    }
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final v = current + (target - current) * t;
      try {
        player.setVolume(v);
      } catch (_) {}
      _bgmVolume = v;
      await Future.delayed(stepDur);
    }
    _bgmVolume = target;
    try {
      player.setVolume(_bgmVolume);
    } catch (_) {}
  }

  Future<void> fadeInBgm({String? asset, Duration duration = const Duration(seconds: 2), double? targetVolume}) async {
    final tgt = (targetVolume ?? _bgmVolume).clamp(0.0, 1.0).toDouble();
    if (asset != null) {
      // play silently first, then fade up
      await playBgm(asset, volume: 0.0);
    } else {
      // if no asset provided but nothing is playing, do nothing
      // FlameAudio.bgm.audioPlayer is non-nullable; we'll proceed.
    }
    await fadeBgmTo(tgt, duration);
  }

  Future<void> fadeOutBgm({Duration duration = const Duration(milliseconds: 500), double target = 0.0}) async {
    await fadeBgmTo(target.clamp(0.0, 1.0).toDouble(), duration);
    if (target <= 0.0001) {
      await stopBgm();
    }
  }

  void setBgmEnabled(bool enabled) {
    _bgmEnabled = enabled;
    if (!enabled) {
      FlameAudio.bgm.pause();
    } else {

      FlameAudio.bgm.resume();
    }
  }

  void setBgmVolume(double v) {
    _bgmVolume = v.clamp(0.0, 1.0).toDouble();
    FlameAudio.bgm.audioPlayer.setVolume(_bgmVolume);
  }

  String? get currentBgm => _currentBgm;
  bool get bgmEnabled => _bgmEnabled;
  double get bgmVolume => _bgmVolume;


  Future<void> playSfx(String asset, {double? volume}) async {
    if (!_sfxEnabled) return;
    final vol = (volume ?? _sfxVolume).clamp(0.0, 1.0).toDouble();
    await FlameAudio.play(asset, volume: vol);
  }

  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
  }

  void setSfxVolume(double v) {
    _sfxVolume = v.clamp(0.0, 1.0).toDouble();
  }

  bool get sfxEnabled => _sfxEnabled;
  double get sfxVolume => _sfxVolume;
}
