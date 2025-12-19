import { Controller, Get, Query } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { getSurahName } from './surah-names';

@Controller('daily')
export class DailyController {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get daily content (verse of day, tafsir, prayer)
   */
  @Get()
  async getDailyContent() {
    // Get today's date seed for consistent daily selection
    const today = new Date();
    const dayOfYear = Math.floor(
      (today.getTime() - new Date(today.getFullYear(), 0, 0).getTime()) /
        (1000 * 60 * 60 * 24),
    );

    // Get total verse count
    const totalVerses = await this.prisma.quranVerse.count();

    if (totalVerses === 0) {
      return this.getDefaultContent();
    }

    // Select verse based on day of year (rotates through all verses)
    const verseIndex = dayOfYear % totalVerses;

    const verse = await this.prisma.quranVerse.findFirst({
      skip: verseIndex,
      take: 1,
    });

    if (!verse) {
      return this.getDefaultContent();
    }

    // Get a different verse for tafsir (offset by 30 days)
    const tafsirIndex = (dayOfYear + 30) % totalVerses;
    const tafsirVerse = await this.prisma.quranVerse.findFirst({
      skip: tafsirIndex,
      take: 1,
    });

    // Get Hijri date (approximate calculation)
    const hijriDate = this.getApproximateHijriDate(today);

    // Sample prayers (will be from database in future)
    const prayers = [
      {
        arabic:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
        turkish:
          'Rabbimiz! Bize dünyada iyilik ver, ahirette de iyilik ver ve bizi ateş azabından koru.',
        source: 'Bakara 201',
      },
      {
        arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
        turkish: 'Rabbim! Göğsümü aç, işimi kolaylaştır.',
        source: 'Tâ-Hâ 25-26',
      },
      {
        arabic:
          'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً',
        turkish:
          'Rabbimiz! Bizi doğru yola ilettikten sonra kalplerimizi eğriltme.',
        source: 'Âl-i İmrân 8',
      },
      {
        arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
        turkish: 'Allah bize yeter. O ne güzel vekildir!',
        source: 'Âl-i İmrân 173',
      },
      {
        arabic: 'رَبِّ زِدْنِي عِلْمًا',
        turkish: 'Rabbim! İlmimi artır.',
        source: 'Tâ-Hâ 114',
      },
      {
        arabic:
          'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
        turkish:
          'Senden başka ilâh yoktur. Seni tenzih ederim. Gerçekten ben zalimlerden oldum.',
        source: 'Enbiyâ 87',
      },
    ];

    const prayerIndex = dayOfYear % prayers.length;
    const dailyPrayer = prayers[prayerIndex];

    return {
      date: {
        gregorian: today.toISOString().split('T')[0],
        hijri: hijriDate,
      },
      verseOfDay: {
        surah: verse.surah,
        ayah: verse.ayah,
        surahName: verse.surah_name || getSurahName(verse.surah),
        arabic: verse.text_ar,
        turkish: verse.text_tr,
      },
      tafsir: tafsirVerse
        ? {
            surah: tafsirVerse.surah,
            ayah: tafsirVerse.ayah,
            surahName: tafsirVerse.surah_name || getSurahName(tafsirVerse.surah),
            arabic: tafsirVerse.text_ar,
            turkish: tafsirVerse.text_tr,
            commentary:
              'Bu ayet, Allah\'ın kullarına olan merhametini ve hidayetini göstermektedir.',
          }
        : null,
      prayer: dailyPrayer,
    };
  }

  /**
   * Get random verse for sharing
   */
  @Get('random-verse')
  async getRandomVerse() {
    const totalVerses = await this.prisma.quranVerse.count();

    if (totalVerses === 0) {
      return {
        surah: 1,
        ayah: 1,
        surahName: 'Fatiha',
        arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        turkish: "Rahmân ve Rahîm olan Allah'ın adıyla.",
      };
    }

    const randomIndex = Math.floor(Math.random() * totalVerses);
    const verse = await this.prisma.quranVerse.findFirst({
      skip: randomIndex,
      take: 1,
    });

    return {
      surah: verse.surah,
      ayah: verse.ayah,
      surahName: verse.surah_name || getSurahName(verse.surah),
      arabic: verse.text_ar,
      turkish: verse.text_tr,
    };
  }

  /**
   * Get random prayer
   */
  @Get('random-prayer')
  async getRandomPrayer() {
    const prayers = [
      {
        arabic:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
        turkish:
          'Rabbimiz! Bize dünyada iyilik ver, ahirette de iyilik ver ve bizi ateş azabından koru.',
        source: 'Bakara 201',
      },
      {
        arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
        turkish: 'Rabbim! Göğsümü aç, işimi kolaylaştır.',
        source: 'Tâ-Hâ 25-26',
      },
      {
        arabic:
          'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً',
        turkish:
          'Rabbimiz! Bizi doğru yola ilettikten sonra kalplerimizi eğriltme.',
        source: 'Âl-i İmrân 8',
      },
      {
        arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
        turkish: 'Allah bize yeter. O ne güzel vekildir!',
        source: 'Âl-i İmrân 173',
      },
      {
        arabic: 'رَبِّ زِدْنِي عِلْمًا',
        turkish: 'Rabbim! İlmimi artır.',
        source: 'Tâ-Hâ 114',
      },
      {
        arabic:
          'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
        turkish:
          'Senden başka ilâh yoktur. Seni tenzih ederim. Gerçekten ben zalimlerden oldum.',
        source: 'Enbiyâ 87',
      },
      {
        arabic: 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي',
        turkish:
          'Rabbim! Beni ve soyumdan gelecekleri namazı dosdoğru kılanlardan eyle.',
        source: 'İbrâhîm 40',
      },
      {
        arabic:
          'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ',
        turkish:
          'Rabbimiz! Bize eşlerimizden ve çocuklarımızdan göz aydınlığı olacak kimseler bağışla.',
        source: 'Furkân 74',
      },
    ];

    const randomIndex = Math.floor(Math.random() * prayers.length);
    return prayers[randomIndex];
  }

  private getDefaultContent() {
    return {
      date: {
        gregorian: new Date().toISOString().split('T')[0],
        hijri: '1446-06-07',
      },
      verseOfDay: {
        surah: 1,
        ayah: 1,
        surahName: 'Fatiha',
        arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        turkish: "Rahmân ve Rahîm olan Allah'ın adıyla.",
      },
      tafsir: null,
      prayer: {
        arabic:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
        turkish:
          'Rabbimiz! Bize dünyada iyilik ver, ahirette de iyilik ver ve bizi ateş azabından koru.',
        source: 'Bakara 201',
      },
    };
  }

  private getApproximateHijriDate(gregorian: Date): string {
    // Approximate Hijri date calculation
    // This is a simplified version - for production use a proper library
    const gregorianYear = gregorian.getFullYear();
    const gregorianMonth = gregorian.getMonth() + 1;
    const gregorianDay = gregorian.getDate();

    // Approximate conversion formula
    const jd =
      Math.floor((1461 * (gregorianYear + 4800 + (gregorianMonth - 14) / 12)) / 4) +
      Math.floor((367 * (gregorianMonth - 2 - 12 * ((gregorianMonth - 14) / 12))) / 12) -
      Math.floor((3 * ((gregorianYear + 4900 + (gregorianMonth - 14) / 12) / 100)) / 4) +
      gregorianDay -
      32075;

    const l = jd - 1948440 + 10632;
    const n = Math.floor((l - 1) / 10631);
    const remainingL = l - 10631 * n + 354;
    const j =
      Math.floor((10985 - remainingL) / 5316) *
        Math.floor((50 * remainingL) / 17719) +
      Math.floor(remainingL / 5670) *
        Math.floor((43 * remainingL) / 15238);
    const adjustedL =
      remainingL -
      Math.floor((30 - j) / 15) * Math.floor((17719 * j) / 50) -
      Math.floor(j / 16) * Math.floor((15238 * j) / 43) +
      29;
    const hijriMonth = Math.floor((24 * adjustedL) / 709);
    const hijriDay = adjustedL - Math.floor((709 * hijriMonth) / 24);
    const hijriYear = 30 * n + j - 30;

    return `${hijriYear}-${String(hijriMonth).padStart(2, '0')}-${String(hijriDay).padStart(2, '0')}`;
  }
}



