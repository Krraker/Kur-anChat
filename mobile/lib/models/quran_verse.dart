class QuranVerse {
  final int id;
  final int surah;
  final String? surahName;
  final int ayah;
  final String textAr;
  final String textTr;

  QuranVerse({
    required this.id,
    required this.surah,
    this.surahName,
    required this.ayah,
    required this.textAr,
    required this.textTr,
  });

  factory QuranVerse.fromJson(Map<String, dynamic> json) {
    return QuranVerse(
      id: json['id'] as int,
      surah: json['surah'] as int,
      surahName: json['surah_name'] as String?,
      ayah: json['ayah'] as int,
      textAr: json['text_ar'] as String,
      textTr: json['text_tr'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surah': surah,
      'surah_name': surahName,
      'ayah': ayah,
      'text_ar': textAr,
      'text_tr': textTr,
    };
  }
}


