import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _backgroundMusic = AudioPlayer();
  
  bool _isMusicOn = true;
  double _volume = 0.5; // 0.0 to 1.0
  
  // Singleton pattern
  factory AudioService() {
    return _instance;
  }
  
  AudioService._internal();
  
  // Initialize and load saved preferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMusicOn = prefs.getBool('isMusicOn') ?? true;
      _volume = prefs.getDouble('volume') ?? 0.5;
      
      // Set initial volume
      await _backgroundMusic.setVolume(_volume);
      
      // Set looping
      await _backgroundMusic.setLoopMode(LoopMode.one);
      
      // Play music if it should be on
      if (_isMusicOn) {
        await playBackgroundMusic();
      }
    } catch (e) {
      debugPrint('Error initializing AudioService: $e');
    }
  }
  
  // Play background music
  Future<void> playBackgroundMusic() async {
    try {
      // Replace with your actual music file path
      await _backgroundMusic.setAsset('assets/audio/background_music.mp3');
      if (_isMusicOn) {
        await _backgroundMusic.play();
      }
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }
  
  // Pause background music
  Future<void> pauseBackgroundMusic() async {
    try {
      await _backgroundMusic.pause();
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
      // Convert 0-100 scale to 0-1 scale
      _volume = volume / 100;
      
      await _backgroundMusic.setVolume(_volume);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('volume', _volume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }
  
  // Get current volume (0-100 scale)
  double getVolume() {
    return _volume * 100;
  }
  
  // Get music on/off state
  bool isMusicOn() {
    return _isMusicOn;
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