import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Service for fetching daily content from the backend
class DailyContentService {
  final ApiConfig _config = ApiConfig();
  final http.Client _client = http.Client();

  String get baseUrl => _config.activeUrl;

  /// Get daily content (verse of day, tafsir, prayer)
  Future<DailyContentResponse> getDailyContent() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/daily'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DailyContentResponse.fromJson(data);
      } else {
        throw DailyContentException(
          'Failed to fetch daily content: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Return fallback content on error
      return DailyContentResponse.fallback();
    }
  }

  /// Get a random verse for sharing
  Future<VerseData> getRandomVerse() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/daily/random-verse'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VerseData.fromJson(data);
      } else {
        throw DailyContentException('Failed to fetch random verse');
      }
    } catch (e) {
      return VerseData.fallback();
    }
  }

  /// Get a random prayer
  Future<PrayerData> getRandomPrayer() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/daily/random-prayer'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PrayerData.fromJson(data);
      } else {
        throw DailyContentException('Failed to fetch random prayer');
      }
    } catch (e) {
      return PrayerData.fallback();
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Daily content response model
class DailyContentResponse {
  final DateInfo date;
  final VerseData verseOfDay;
  final TafsirData? tafsir;
  final PrayerData prayer;

  DailyContentResponse({
    required this.date,
    required this.verseOfDay,
    this.tafsir,
    required this.prayer,
  });

  factory DailyContentResponse.fromJson(Map<String, dynamic> json) {
    return DailyContentResponse(
      date: DateInfo.fromJson(json['date']),
      verseOfDay: VerseData.fromJson(json['verseOfDay']),
      tafsir: json['tafsir'] != null ? TafsirData.fromJson(json['tafsir']) : null,
      prayer: PrayerData.fromJson(json['prayer']),
    );
  }

  factory DailyContentResponse.fallback() {
    return DailyContentResponse(
      date: DateInfo(gregorian: DateTime.now().toString().split(' ')[0], hijri: '1446-06-07'),
      verseOfDay: VerseData.fallback(),
      tafsir: null,
      prayer: PrayerData.fallback(),
    );
  }
}

class DateInfo {
  final String gregorian;
  final String hijri;

  DateInfo({required this.gregorian, required this.hijri});

  factory DateInfo.fromJson(Map<String, dynamic> json) {
    return DateInfo(
      gregorian: json['gregorian'] ?? '',
      hijri: json['hijri'] ?? '',
    );
  }
}

class VerseData {
  final int surah;
  final int ayah;
  final String surahName;
  final String arabic;
  final String turkish;

  VerseData({
    required this.surah,
    required this.ayah,
    required this.surahName,
    required this.arabic,
    required this.turkish,
  });

  factory VerseData.fromJson(Map<String, dynamic> json) {
    return VerseData(
      surah: json['surah'] ?? 1,
      ayah: json['ayah'] ?? 1,
      surahName: json['surahName'] ?? 'Fatiha',
      arabic: json['arabic'] ?? '',
      turkish: json['turkish'] ?? '',
    );
  }

  factory VerseData.fallback() {
    return VerseData(
      surah: 2,
      ayah: 286,
      surahName: 'Bakara',
      arabic: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      turkish: 'Allah hiç kimseye gücünün üstünde bir yük yüklemez.',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surah': surah,
      'surahTr': surahName,
      'ayah': ayah,
      'arabic': arabic,
      'meaning': turkish,
    };
  }
}

class TafsirData {
  final int surah;
  final int ayah;
  final String surahName;
  final String arabic;
  final String turkish;
  final String? commentary;

  TafsirData({
    required this.surah,
    required this.ayah,
    required this.surahName,
    required this.arabic,
    required this.turkish,
    this.commentary,
  });

  factory TafsirData.fromJson(Map<String, dynamic> json) {
    return TafsirData(
      surah: json['surah'] ?? 1,
      ayah: json['ayah'] ?? 1,
      surahName: json['surahName'] ?? '',
      arabic: json['arabic'] ?? '',
      turkish: json['turkish'] ?? '',
      commentary: json['commentary'],
    );
  }
}

class PrayerData {
  final String arabic;
  final String turkish;
  final String? source;

  PrayerData({
    required this.arabic,
    required this.turkish,
    this.source,
  });

  factory PrayerData.fromJson(Map<String, dynamic> json) {
    return PrayerData(
      arabic: json['arabic'] ?? '',
      turkish: json['turkish'] ?? '',
      source: json['source'],
    );
  }

  factory PrayerData.fallback() {
    return PrayerData(
      arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      turkish: 'Rabbimiz! Bize dünyada iyilik ver, ahirette de iyilik ver ve bizi ateş azabından koru.',
      source: 'Bakara 201',
    );
  }

  Map<String, String> toMap() {
    return {
      'arabic': arabic,
      'meaning': turkish,
    };
  }
}

class DailyContentException implements Exception {
  final String message;
  DailyContentException(this.message);

  @override
  String toString() => message;
}


