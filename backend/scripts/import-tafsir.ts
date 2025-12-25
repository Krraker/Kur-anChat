/**
 * Tafsir Import Script
 * Imports tafsir (commentary) data for Quran verses
 * 
 * Usage: npx ts-node scripts/import-tafsir.ts
 */

import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Quran.com API base
const API_BASE = 'https://api.quran.com/api/v4';

// Turkish Tafsir IDs from Quran.com
// 166 = Turkish Diyanet Tafsir
const TAFSIR_RESOURCES = [
  { id: 166, name: 'Diyanet Tefsiri' },
];

// Helper function for delay
const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

// Fetch with retry
async function fetchWithRetry(url: string, retries = 3): Promise<any> {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      return await response.json();
    } catch (error) {
      console.log(`  ⚠️ Retry ${i + 1}/${retries}`);
      if (i === retries - 1) throw error;
      await delay(2000 * (i + 1));
    }
  }
}

// Surah verse counts
const SURAH_VERSES: { [key: number]: number } = {
  1: 7, 2: 286, 3: 200, 4: 176, 5: 120, 6: 165, 7: 206, 8: 75, 9: 129, 10: 109,
  11: 123, 12: 111, 13: 43, 14: 52, 15: 99, 16: 128, 17: 111, 18: 110, 19: 98, 20: 135,
  21: 112, 22: 78, 23: 118, 24: 64, 25: 77, 26: 227, 27: 93, 28: 88, 29: 69, 30: 60,
  31: 34, 32: 30, 33: 73, 34: 54, 35: 45, 36: 83, 37: 182, 38: 88, 39: 75, 40: 85,
  41: 54, 42: 53, 43: 89, 44: 59, 45: 37, 46: 35, 47: 38, 48: 29, 49: 18, 50: 45,
  51: 60, 52: 49, 53: 62, 54: 55, 55: 78, 56: 96, 57: 29, 58: 22, 59: 24, 60: 13,
  61: 14, 62: 11, 63: 11, 64: 18, 65: 12, 66: 12, 67: 30, 68: 52, 69: 52, 70: 44,
  71: 28, 72: 28, 73: 20, 74: 56, 75: 40, 76: 31, 77: 50, 78: 40, 79: 46, 80: 42,
  81: 29, 82: 19, 83: 36, 84: 25, 85: 22, 86: 17, 87: 19, 88: 26, 89: 30, 90: 20,
  91: 15, 92: 21, 93: 11, 94: 8, 95: 8, 96: 19, 97: 5, 98: 8, 99: 8, 100: 11,
  101: 11, 102: 8, 103: 3, 104: 9, 105: 5, 106: 4, 107: 7, 108: 3, 109: 6, 110: 3,
  111: 5, 112: 4, 113: 5, 114: 6,
};

// Import tafsir for a single verse
async function importTafsirForVerse(
  surah: number,
  ayah: number,
  tafsirId: number,
  tafsirName: string,
): Promise<boolean> {
  try {
    const url = `${API_BASE}/tafsirs/${tafsirId}/by_ayah/${surah}:${ayah}`;
    const data = await fetchWithRetry(url);

    if (data.tafsir && data.tafsir.text) {
      // Clean HTML tags
      const cleanText = data.tafsir.text
        .replace(/<[^>]*>/g, '')
        .replace(/\s+/g, ' ')
        .trim();

      if (cleanText.length > 10) {
        await prisma.tafsir.upsert({
          where: {
            surah_ayah_source: {
              surah,
              ayah,
              source: tafsirName,
            },
          },
          update: { text: cleanText },
          create: {
            surah,
            ayah,
            source: tafsirName,
            text: cleanText,
          },
        });
        return true;
      }
    }
    return false;
  } catch (error) {
    return false;
  }
}

// Import tafsir for important verses first
async function importPopularVersesTafsir(): Promise<number> {
  console.log('\n📚 Importing tafsir for popular verses...\n');

  // Important/popular verses to prioritize
  const popularVerses = [
    // Fatiha (all)
    ...Array.from({ length: 7 }, (_, i) => ({ surah: 1, ayah: i + 1 })),
    // Ayetel Kursi
    { surah: 2, ayah: 255 },
    // Last verses of Bakara
    { surah: 2, ayah: 285 },
    { surah: 2, ayah: 286 },
    // Popular Bakara verses
    { surah: 2, ayah: 152 },
    { surah: 2, ayah: 153 },
    { surah: 2, ayah: 155 },
    { surah: 2, ayah: 156 },
    { surah: 2, ayah: 185 },
    { surah: 2, ayah: 186 },
    { surah: 2, ayah: 201 },
    // Al-i Imran
    { surah: 3, ayah: 8 },
    { surah: 3, ayah: 139 },
    { surah: 3, ayah: 159 },
    { surah: 3, ayah: 173 },
    // Rad
    { surah: 13, ayah: 11 },
    { surah: 13, ayah: 28 },
    // Ibrahim
    { surah: 14, ayah: 7 },
    // Isra
    { surah: 17, ayah: 23 },
    { surah: 17, ayah: 80 },
    // Enbiya
    { surah: 21, ayah: 87 },
    // Ankebut
    { surah: 29, ayah: 45 },
    { surah: 29, ayah: 69 },
    // Zumar
    { surah: 39, ayah: 53 },
    // Fussilet
    { surah: 41, ayah: 34 },
    // Hucurat
    { surah: 49, ayah: 10 },
    { surah: 49, ayah: 11 },
    { surah: 49, ayah: 12 },
    { surah: 49, ayah: 13 },
    // Rahman
    { surah: 55, ayah: 13 },
    // Talak
    { surah: 65, ayah: 2 },
    { surah: 65, ayah: 3 },
    // Mulk (first 10)
    ...Array.from({ length: 10 }, (_, i) => ({ surah: 67, ayah: i + 1 })),
    // Short surahs (complete)
    // Duha
    ...Array.from({ length: 11 }, (_, i) => ({ surah: 93, ayah: i + 1 })),
    // Insirah
    ...Array.from({ length: 8 }, (_, i) => ({ surah: 94, ayah: i + 1 })),
    // Asr
    ...Array.from({ length: 3 }, (_, i) => ({ surah: 103, ayah: i + 1 })),
    // Ihlas
    ...Array.from({ length: 4 }, (_, i) => ({ surah: 112, ayah: i + 1 })),
    // Felak
    ...Array.from({ length: 5 }, (_, i) => ({ surah: 113, ayah: i + 1 })),
    // Nas
    ...Array.from({ length: 6 }, (_, i) => ({ surah: 114, ayah: i + 1 })),
  ];

  let imported = 0;

  for (const resource of TAFSIR_RESOURCES) {
    console.log(`📖 Importing from: ${resource.name}`);
    
    for (const verse of popularVerses) {
      const success = await importTafsirForVerse(
        verse.surah,
        verse.ayah,
        resource.id,
        resource.name,
      );
      
      if (success) {
        imported++;
        process.stdout.write(`\r  ✅ Imported ${imported} tafsirs...`);
      }
      
      // Rate limiting
      await delay(100);
    }
    console.log();
  }

  return imported;
}

// Import tafsir for all verses (optional - takes a long time)
async function importAllTafsir(): Promise<number> {
  console.log('\n📚 Importing tafsir for ALL verses (this will take a while)...\n');

  let imported = 0;
  let failed = 0;

  for (const resource of TAFSIR_RESOURCES) {
    console.log(`📖 Source: ${resource.name}`);

    for (let surah = 1; surah <= 114; surah++) {
      const verseCount = SURAH_VERSES[surah];
      let surahImported = 0;

      for (let ayah = 1; ayah <= verseCount; ayah++) {
        const success = await importTafsirForVerse(
          surah,
          ayah,
          resource.id,
          resource.name,
        );

        if (success) {
          imported++;
          surahImported++;
        } else {
          failed++;
        }

        // Rate limiting
        await delay(50);
      }

      console.log(`  Surah ${surah}: ${surahImported}/${verseCount} tafsirs imported`);

      // Progress every 10 surahs
      if (surah % 10 === 0) {
        const progress = ((surah / 114) * 100).toFixed(1);
        console.log(`\n📊 Progress: ${progress}% (${imported} imported, ${failed} failed)\n`);
      }
    }
  }

  return imported;
}

async function main() {
  console.log('🕌 Starting Tafsir Import');
  console.log('=========================\n');

  const startTime = Date.now();

  // Check if we should import all or just popular
  const importAll = process.argv.includes('--all');

  let imported: number;
  
  if (importAll) {
    imported = await importAllTafsir();
  } else {
    imported = await importPopularVersesTafsir();
    console.log('\n💡 Tip: Run with --all flag to import tafsir for ALL verses');
  }

  const duration = ((Date.now() - startTime) / 1000 / 60).toFixed(1);

  // Get stats
  const stats = await prisma.tafsir.count();
  const uniqueVerses = await prisma.tafsir.groupBy({
    by: ['surah', 'ayah'],
  });

  console.log('\n=========================');
  console.log('🎉 Tafsir Import Complete!');
  console.log('=========================');
  console.log(`✅ Total tafsirs in DB: ${stats}`);
  console.log(`📚 Verses with tafsir: ${uniqueVerses.length}/6236`);
  console.log(`📊 Coverage: ${((uniqueVerses.length / 6236) * 100).toFixed(1)}%`);
  console.log(`⏱️ Duration: ${duration} minutes`);
}

main()
  .catch((e) => {
    console.error('Fatal error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });





