import { Controller, Get, Param, Query, ParseIntPipe } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { getSurahName } from './surah-names';

@Controller('tafsir')
export class TafsirController {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get tafsir for a specific verse
   */
  @Get(':surah/:ayah')
  async getTafsir(
    @Param('surah', ParseIntPipe) surah: number,
    @Param('ayah', ParseIntPipe) ayah: number,
    @Query('source') source?: string,
  ) {
    const where: any = { surah, ayah };
    if (source) {
      where.source = source;
    }

    const tafsirs = await this.prisma.tafsir.findMany({
      where,
      orderBy: { source: 'asc' },
    });

    // Get the verse itself
    const verse = await this.prisma.quranVerse.findUnique({
      where: { surah_ayah: { surah, ayah } },
    });

    if (tafsirs.length === 0) {
      // Return GPT-generated placeholder tafsir
      return {
        surah,
        ayah,
        surahName: verse?.surah_name || getSurahName(surah),
        verse: verse
          ? {
              arabic: verse.text_ar,
              turkish: verse.text_tr,
            }
          : null,
        tafsirs: [
          {
            source: 'Özet',
            text: this.generatePlaceholderTafsir(verse?.text_tr || ''),
          },
        ],
        note: 'Detaylı tefsir yakında eklenecektir.',
      };
    }

    return {
      surah,
      ayah,
      surahName: verse?.surah_name || getSurahName(surah),
      verse: verse
        ? {
            arabic: verse.text_ar,
            turkish: verse.text_tr,
          }
        : null,
      tafsirs: tafsirs.map((t) => ({
        source: t.source,
        text: t.text,
      })),
    };
  }

  /**
   * Get available tafsir sources
   */
  @Get('sources')
  async getSources() {
    const sources = await this.prisma.tafsir.groupBy({
      by: ['source'],
      _count: { source: true },
    });

    return {
      sources: sources.map((s) => ({
        name: s.source,
        count: s._count.source,
      })),
    };
  }

  /**
   * Get tafsir statistics
   */
  @Get('stats')
  async getStats() {
    const totalTafsirs = await this.prisma.tafsir.count();
    const bySource = await this.prisma.tafsir.groupBy({
      by: ['source'],
      _count: { source: true },
    });

    const uniqueVerses = await this.prisma.tafsir.groupBy({
      by: ['surah', 'ayah'],
    });

    return {
      totalTafsirs,
      uniqueVersesWithTafsir: uniqueVerses.length,
      totalVersesInQuran: 6236,
      coverage: `${((uniqueVerses.length / 6236) * 100).toFixed(1)}%`,
      bySource: bySource.map((s) => ({
        source: s.source,
        count: s._count.source,
      })),
    };
  }

  /**
   * Generate a simple placeholder tafsir based on verse content
   */
  private generatePlaceholderTafsir(verseText: string): string {
    if (!verseText) {
      return 'Bu ayet hakkında tefsir bilgisi henüz eklenmemiştir.';
    }

    // Simple keyword-based tafsir hints
    const keywords: { [key: string]: string } = {
      Allah: 'Bu ayette Allah\'ın yüceliği ve kudreti vurgulanmaktadır.',
      iman: 'Bu ayet iman esaslarını ve müminin özelliklerini açıklamaktadır.',
      sabır: 'Sabır ve tevekkülün önemi bu ayette işlenmektedir.',
      namaz: 'Namaz ibadeti ve önemi bu ayette anlatılmaktadır.',
      zekât: 'Zekât ve infakın fazileti bu ayette belirtilmektedir.',
      cennet: 'Cennet nimetleri ve mükâfatlar bu ayette tasvir edilmektedir.',
      cehennem:
        'Ahiret azabı ve kötülerin akıbeti bu ayette uyarı olarak verilmektedir.',
      peygamber: 'Peygamberlerin kıssası ve örnekliği bu ayette anlatılmaktadır.',
      dua: 'Dua adabı ve önemi bu ayette öğretilmektedir.',
      şükür: 'Şükrün önemi ve nimete karşılık bu ayette vurgulanmaktadır.',
      tövbe: 'Tövbenin fazileti ve Allah\'ın affediciliği bu ayette işlenmektedir.',
    };

    for (const [keyword, description] of Object.entries(keywords)) {
      if (verseText.toLowerCase().includes(keyword.toLowerCase())) {
        return description;
      }
    }

    return 'Bu ayet, Kur\'an-ı Kerim\'in derin hikmetlerinden birini içermektedir. Detaylı tefsir için İslam alimlerinin eserlerine başvurabilirsiniz.';
  }
}
