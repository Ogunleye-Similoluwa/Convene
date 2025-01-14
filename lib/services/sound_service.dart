import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  
  static const _vibrationPatterns = {
    'notification': [100, 50, 100],
    'success': [50, 100],
    'error': [100, 50, 100, 50, 100],
  };

  Future<void> playNotificationSound({String type = 'default'}) async {
    try {
      await _player.setAsset('assets/sounds/$type.mp3');
      await _player.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  Future<void> vibrate({String pattern = 'notification'}) async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;

    final vibrationPattern = _vibrationPatterns[pattern] ?? [100];
    Vibration.vibrate(pattern: vibrationPattern);
  }

  void dispose() {
    _player.dispose();
  }
} 