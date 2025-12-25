import { Controller, Get, Param, Query, ParseIntPipe } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { getSurahName } from './surah-names';

// Surah metadata
const surahInfo: Record<
  number,
  { verses: number; revelationType: 'Meccan' | 'Medinan' }
> = {
  1: { verses: 7, revelationType: 'Meccan' },
  2: { verses: 286, revelationType: 'Medinan' },
  3: { verses: 200, revelationType: 'Medinan' },
  4: { verses: 176, revelationType: 'Medinan' },
  5: { verses: 120, revelationType: 'Medinan' },
  6: { verses: 165, revelationType: 'Meccan' },
  7: { verses: 206, revelationType: 'Meccan' },
  // ... Add more as needed
  112: { verses: 4, revelationType: 'Meccan' },
  113: { verses: 5, revelationType: 'Meccan' },
  114: { verses: 6, revelationType: 'Meccan' },
};

@Controller('quran')
export class QuranController {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get list of all surahs with basic info
   */
  @Get('surahs')
  async getAllSurahs() {
    // Get verse counts from database
    const verseCounts = await this.prisma.quranVerse.groupBy({
      by: ['surah'],
      _count: { ayah: true },
      orderBy: { surah: 'asc' },
    });

    const surahs = [];
    for (let i = 1; i <= 114; i++) {
      const dbCount = verseCounts.find((v) => v.surah === i);
      const info = surahInfo[i] || { verses: 0, revelationType: 'Meccan' };
      surahs.push({
        number: i,
        name: getSurahName(i),
        totalVerses: info.verses,
        availableVerses: dbCount?._count?.ayah || 0,
        revelationType: info.revelationType,
      });
    }

    return surahs;
  }

  /**
   * Get all verses for a specific surah
   */
  @Get('surah/:number')
  async getSurah(@Param('number', ParseIntPipe) surahNumber: number) {
    if (surahNumber < 1 || surahNumber > 114) {
      return { error: 'Invalid surah number. Must be between 1 and 114.' };
    }

    const verses = await this.prisma.quranVerse.findMany({
      where: { surah: surahNumber },
      orderBy: { ayah: 'asc' },
    });

    const info = surahInfo[surahNumber] || { verses: 0, revelationType: 'Meccan' };

    return {
      surah: surahNumber,
      name: getSurahName(surahNumber),
      totalVerses: info.verses,
      availableVerses: verses.length,
      revelationType: info.revelationType,
      verses: verses.map((v) => ({
        ayah: v.ayah,
        arabic: v.text_ar,
        turkish: v.text_tr,
      })),
    };
  }

  /**
   * Get a specific verse
   */
  @Get('surah/:surah/ayah/:ayah')
  async getVerse(
    @Param('surah', ParseIntPipe) surah: number,
    @Param('ayah', ParseIntPipe) ayah: number,
  ) {
    if (surah < 1 || surah > 114) {
      return { error: 'Invalid surah number. Must be between 1 and 114.' };
    }

    const verse = await this.prisma.quranVerse.findUnique({
      where: {
        surah_ayah: { surah, ayah },
      },
    });

    if (!verse) {
      return {
        error: `Verse ${surah}:${ayah} not found in database.`,
        suggestion: 'This verse may not be seeded yet.',
      };
    }

    return {
      surah: verse.surah,
      ayah: verse.ayah,
      surahName: verse.surah_name || getSurahName(verse.surah),
      arabic: verse.text_ar,
      turkish: verse.text_tr,
    };
  }

  /**
   * Search verses by text (Turkish)
   */
  @Get('search')
  async searchVerses(
    @Query('q') query: string,
    @Query('limit') limit?: string,
  ) {
    if (!query || query.length < 2) {
      return { error: 'Search query must be at least 2 characters.' };
    }

    const maxResults = Math.min(parseInt(limit) || 20, 50);

    const verses = await this.prisma.quranVerse.findMany({
      where: {
        OR: [
          { text_tr: { contains: query, mode: 'insensitive' } },
          { surah_name: { contains: query, mode: 'insensitive' } },
        ],
      },
      take: maxResults,
      orderBy: [{ surah: 'asc' }, { ayah: 'asc' }],
    });

    return {
      query,
      count: verses.length,
      results: verses.map((v) => ({
        surah: v.surah,
        ayah: v.ayah,
        surahName: v.surah_name || getSurahName(v.surah),
        arabic: v.text_ar,
        turkish: v.text_tr,
      })),
    };
  }

  /**
   * Get database statistics
   */
  @Get('stats')
  async getStats() {
    const totalVerses = await this.prisma.quranVerse.count();
    const surahCounts = await this.prisma.quranVerse.groupBy({
      by: ['surah'],
      _count: { ayah: true },
    });

    const completeSurahs = surahCounts.filter((s) => {
      const info = surahInfo[s.surah];
      return info && s._count.ayah >= info.verses;
    }).length;

    return {
      totalVersesInDb: totalVerses,
      totalVersesInQuran: 6236,
      coverage: `${((totalVerses / 6236) * 100).toFixed(1)}%`,
      surahsWithVerses: surahCounts.length,
      completeSurahs,
      totalSurahs: 114,
    };
  }

  /**
   * Get popular/featured verses
   */
  @Get('featured')
  async getFeaturedVerses() {
    // Featured verse references
    const featured = [
      { surah: 2, ayah: 255 }, // Ayetel Kursi
      { surah: 2, ayah: 286 }, // Last verse of Bakara
      { surah: 94, ayah: 5 }, // With hardship comes ease
      { surah: 94, ayah: 6 },
      { surah: 13, ayah: 28 }, // Hearts find peace in Allah's remembrance
      { surah: 3, ayah: 173 }, // Hasbunallah
      { surah: 21, ayah: 87 }, // Yunus's prayer
      { surah: 112, ayah: 1 }, // Ihlas
      { surah: 112, ayah: 2 },
      { surah: 112, ayah: 3 },
      { surah: 112, ayah: 4 },
    ];

    const verses = [];
    for (const ref of featured) {
      const verse = await this.prisma.quranVerse.findUnique({
        where: { surah_ayah: { surah: ref.surah, ayah: ref.ayah } },
      });
      if (verse) {
        verses.push({
          surah: verse.surah,
          ayah: verse.ayah,
          surahName: verse.surah_name || getSurahName(verse.surah),
          arabic: verse.text_ar,
          turkish: verse.text_tr,
        });
      }
    }

    return { count: verses.length, verses };
  }
}







