import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _backgroundMusic = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer(); // for short sounds like click

  bool _isMusicOn = true;
  double _volume = 0.5;
  bool _isInitialized = false;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  bool get isMusicOn => _isMusicOn;
  double get volume => _volume;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isMusicOn = prefs.getBool('isMusicOn') ?? true;
      _volume = prefs.getDouble('volume') ?? 0.5;

      await _backgroundMusic.setVolume(_volume);
      await _backgroundMusic.setLoopMode(LoopMode.one);
      await _backgroundMusic.setAsset('assets/audio/background_music.mp3');

      if (_isMusicOn) {
        await _backgroundMusic.play();
      }

      _isInitialized = true;

    } catch (e) {
      debugPrint('Error initializing AudioService: $e');
    }
  }

  Future<void> playBackgroundMusic() async {
    try {
      if (!_isInitialized) await initialize();
      if (_isMusicOn && !_backgroundMusic.playing) {
        await _backgroundMusic.play();
      }
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      if (_backgroundMusic.playing) {
        await _backgroundMusic.pause();
      }
    } catch (e) {
      debugPrint('Error pausing background music: $e');
    }
  }

  Future<void> toggleMusic(bool isOn) async {
    try {
      _isMusicOn = isOn;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isMusicOn', isOn);

      if (isOn) {
        await _backgroundMusic.play();
      } else {
        await _backgroundMusic.pause();
      }
    } catch (e) {
      debugPrint('Error toggling music: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _backgroundMusic.setVolume(_volume);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('volume', _volume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  void handleLifecycleChange(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      pauseBackgroundMusic();
    } else if (state == AppLifecycleState.resumed && _isMusicOn) {
      _backgroundMusic.play();
    }
  }

  // 🔊 PLAY SHORT CLICK SOUND
  Future<void> playClickSound() async {
    try {
      await _sfxPlayer.setAsset('assets/audio/click.mp3');
      await _sfxPlayer.setVolume(_volume);
      await _sfxPlayer.play();
    } catch (e) {
      debugPrint('Error playing click sound: $e');
    }
  }

  void dispose() {
    _backgroundMusic.dispose();
    _sfxPlayer.dispose();
  }
}
