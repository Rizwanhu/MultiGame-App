import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _backgroundMusic = AudioPlayer();
  
  bool _isMusicOn = true;
  double _volume = 0.5; // 0.0 to 1.0
  bool _isInitialized = false;
  
  // Singleton pattern
  factory AudioService() {
    return _instance;
  }
  
  AudioService._internal();
  
  bool get isMusicOn => _isMusicOn;
  double get volume => _volume;
  
  // Initialize and load saved preferences
  Future<void> initialize() async {
    if (_isInitialized) return; // Only initialize once
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMusicOn = prefs.getBool('isMusicOn') ?? true;
      _volume = prefs.getDouble('volume') ?? 0.5;
      
      // Set initial volume
      await _backgroundMusic.setVolume(_volume);
      
      // Set looping
      await _backgroundMusic.setLoopMode(LoopMode.one);
      
      // Prepare the audio but don't play yet
      await _backgroundMusic.setAsset('assets/audio/background_music.mp3');
      
      // Play music if it should be on
      if (_isMusicOn) {
        await _backgroundMusic.play();
      }
      
      _isInitialized = true;
      
    } catch (e) {
      debugPrint('Error initializing AudioService: $e');
    }
  }
  
  // Play background music
  Future<void> playBackgroundMusic() async {
    try {
      if (!_isInitialized) {
        await initialize();
        return;
      }
      
      if (_isMusicOn && !_backgroundMusic.playing) {
        await _backgroundMusic.play();
      }
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }
  
  // Pause background music
  Future<void> pauseBackgroundMusic() async {
    try {
      if (_backgroundMusic.playing) {
        await _backgroundMusic.pause();
      }
    } catch (e) {
      debugPrint('Error pausing background music: $e');
    }
  }
  
  // Toggle music on/off
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
  
  // Set volume
  Future<void> setVolume(double volume) async {
    try {
      // Ensure volume is between 0.0 and 1.0
      _volume = volume.clamp(0.0, 1.0);
      
      await _backgroundMusic.setVolume(_volume);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('volume', _volume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }
  
  // Handle app lifecycle changes
  void handleLifecycleChange(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      pauseBackgroundMusic();
    } else if (state == AppLifecycleState.resumed && _isMusicOn) {
      _backgroundMusic.play();
    }
  }
  
  // Clean up resources
  void dispose() {
    _backgroundMusic.dispose();
  }
}