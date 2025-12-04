import 'package:flame_audio/flame_audio.dart';
import 'package:idle_universe/core/services/logger_service.dart';

/// AudioService - Manages game audio (BGM & SFX)
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  bool _isInitialized = false;

  // Track current BGM to avoid restarting same track
  String? _currentBgm;

  /// Initialize audio service (preload sounds)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Preload common SFX
      // Note: We need actual assets in assets/audio/sfx/ and assets/audio/music/
      await FlameAudio.audioCache.loadAll([
        'sfx/click.wav',
        'sfx/buy.wav',
        'sfx/upgrade.wav',
        'sfx/achievement.wav',
        'sfx/prestige.wav',
        'music/gameLoopTrack.mp3',
      ]);

      _isInitialized = true;
      LoggerService.info('AudioService initialized');
    } catch (e) {
      LoggerService.error('Failed to initialize AudioService', e);
    }
  }

  /// Play background music
  void playBgm(String fileName) {
    if (!_isMusicEnabled) return;
    if (_currentBgm == fileName) return;

    try {
      FlameAudio.bgm.play('music/$fileName');
      _currentBgm = fileName;
    } catch (e) {
      LoggerService.error('Failed to play BGM: $fileName', e);
    }
  }

  /// Stop background music
  void stopBgm() {
    try {
      FlameAudio.bgm.stop();
      _currentBgm = null;
    } catch (e) {
      LoggerService.error('Failed to stop BGM', e);
    }
  }

  /// Play sound effect
  void playSfx(String fileName) {
    if (!_isSfxEnabled) return;

    try {
      FlameAudio.play('sfx/$fileName');
    } catch (e) {
      LoggerService.error('Failed to play SFX: $fileName', e);
    }
  }

  /// Toggle Music
  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;
    if (!_isMusicEnabled) {
      stopBgm();
    } else if (_currentBgm != null) {
      playBgm(_currentBgm!);
    }
  }

  /// Toggle SFX
  void toggleSfx() {
    _isSfxEnabled = !_isSfxEnabled;
  }

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
}
