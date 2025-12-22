import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'api_config.dart';

enum AudioPlaybackState { idle, loading, playing, paused, completed, error }

class PlayingVerse {
  final int surah;
  final int ayah;
  final String? surahName;
  final String? textTr;

  PlayingVerse({required this.surah, required this.ayah, this.surahName, this.textTr});
}

class QuranAudioService {
  static final QuranAudioService _instance = QuranAudioService._internal();
  factory QuranAudioService() => _instance;
  QuranAudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  
  AudioPlaybackState _state = AudioPlaybackState.idle;
  PlayingVerse? _currentVerse;
  double _playbackSpeed = 1.0;
  
  List<PlayingVerse> _playlist = [];
  int _currentIndex = 0;
  bool _isPlaylistMode = false;

  final List<VoidCallback> _listeners = [];

  AudioPlaybackState get state => _state;
  PlayingVerse? get currentVerse => _currentVerse;
  double get playbackSpeed => _playbackSpeed;
  bool get isPlaying => _state == AudioPlaybackState.playing;
  bool get isPaused => _state == AudioPlaybackState.paused;
  bool get isLoading => _state == AudioPlaybackState.loading;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  Stream<Duration> get positionStream => _player.positionStream;
  bool get hasNext => _isPlaylistMode && _currentIndex < _playlist.length - 1;
  bool get hasPrevious => _isPlaylistMode && _currentIndex > 0;

  Future<void> init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());

      _player.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          _handlePlaybackCompleted();
        }
      });

      debugPrint('QuranAudioService initialized');
    } catch (e) {
      debugPrint('Error initializing audio service: $e');
    }
  }

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  Future<void> playVerse({
    required int surah,
    required int ayah,
    String? surahName,
    String? textTr,
  }) async {
    try {
      _setState(AudioPlaybackState.loading);
      _isPlaylistMode = false;
      
      _currentVerse = PlayingVerse(surah: surah, ayah: ayah, surahName: surahName, textTr: textTr);
      _notifyListeners();

      final audioUrl = '${ApiConfig.baseUrl}/audio/verse/$surah/$ayah';
      debugPrint('Playing audio from: $audioUrl');

      await _player.setUrl(audioUrl);
      await _player.setSpeed(_playbackSpeed);
      await _player.play();

      _setState(AudioPlaybackState.playing);
    } catch (e) {
      debugPrint('Error playing verse: $e');
      _setState(AudioPlaybackState.error);
    }
  }

  Future<void> playPlaylist({required List<PlayingVerse> verses, int startIndex = 0}) async {
    if (verses.isEmpty) return;
    _playlist = verses;
    _currentIndex = startIndex.clamp(0, verses.length - 1);
    _isPlaylistMode = true;
    await _playCurrentPlaylistItem();
  }

  Future<void> _playCurrentPlaylistItem() async {
    if (_currentIndex >= _playlist.length) {
      _setState(AudioPlaybackState.completed);
      return;
    }
    final verse = _playlist[_currentIndex];
    await playVerse(surah: verse.surah, ayah: verse.ayah, surahName: verse.surahName, textTr: verse.textTr);
  }

  void _handlePlaybackCompleted() {
    if (_isPlaylistMode && _currentIndex < _playlist.length - 1) {
      _currentIndex++;
      _playCurrentPlaylistItem();
    } else {
      _setState(AudioPlaybackState.completed);
    }
  }

  Future<void> playNext() async {
    if (!hasNext) return;
    _currentIndex++;
    await _playCurrentPlaylistItem();
  }

  Future<void> playPrevious() async {
    if (!hasPrevious) return;
    _currentIndex--;
    await _playCurrentPlaylistItem();
  }

  Future<void> pause() async {
    await _player.pause();
    _setState(AudioPlaybackState.paused);
  }

  Future<void> resume() async {
    await _player.play();
    _setState(AudioPlaybackState.playing);
  }

  Future<void> stop() async {
    await _player.stop();
    _currentVerse = null;
    _playlist = [];
    _isPlaylistMode = false;
    _setState(AudioPlaybackState.idle);
  }

  Future<void> seek(Duration position) async => await _player.seek(position);

  Future<void> setSpeed(double speed) async {
    _playbackSpeed = speed.clamp(0.5, 2.0);
    await _player.setSpeed(_playbackSpeed);
    _notifyListeners();
  }

  void _setState(AudioPlaybackState newState) {
    _state = newState;
    _notifyListeners();
  }

  Future<void> dispose() async {
    await _player.dispose();
    _listeners.clear();
  }
}
