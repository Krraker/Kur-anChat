/**
 * Quran Import Script
 * Fetches all 6,236 verses from Quran.com API and imports into database
 * 
 * Usage: npx ts-node scripts/import-quran.ts
 */

import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Quran.com API base URL
const API_BASE = 'https://api.quran.com/api/v4';

// Turkish translation ID (Diyanet İşleri)
const TURKISH_TRANSLATION_ID = 77; // Diyanet Vakfı Meali

// Surah info (total verses per surah)
const SURAH_INFO: { [key: number]: { name_tr: string; verses: number } } = {
  1: { name_tr: 'Fâtiha', verses: 7 },
  2: { name_tr: 'Bakara', verses: 286 },
  3: { name_tr: 'Âl-i İmrân', verses: 200 },
  4: { name_tr: 'Nisâ', verses: 176 },
  5: { name_tr: 'Mâide', verses: 120 },
  6: { name_tr: 'En\'âm', verses: 165 },
  7: { name_tr: 'A\'râf', verses: 206 },
  8: { name_tr: 'Enfâl', verses: 75 },
  9: { name_tr: 'Tevbe', verses: 129 },
  10: { name_tr: 'Yûnus', verses: 109 },
  11: { name_tr: 'Hûd', verses: 123 },
  12: { name_tr: 'Yûsuf', verses: 111 },
  13: { name_tr: 'Ra\'d', verses: 43 },
  14: { name_tr: 'İbrâhîm', verses: 52 },
  15: { name_tr: 'Hicr', verses: 99 },
  16: { name_tr: 'Nahl', verses: 128 },
  17: { name_tr: 'İsrâ', verses: 111 },
  18: { name_tr: 'Kehf', verses: 110 },
  19: { name_tr: 'Meryem', verses: 98 },
  20: { name_tr: 'Tâ-Hâ', verses: 135 },
  21: { name_tr: 'Enbiyâ', verses: 112 },
  22: { name_tr: 'Hac', verses: 78 },
  23: { name_tr: 'Mü\'minûn', verses: 118 },
  24: { name_tr: 'Nûr', verses: 64 },
  25: { name_tr: 'Furkân', verses: 77 },
  26: { name_tr: 'Şuarâ', verses: 227 },
  27: { name_tr: 'Neml', verses: 93 },
  28: { name_tr: 'Kasas', verses: 88 },
  29: { name_tr: 'Ankebût', verses: 69 },
  30: { name_tr: 'Rûm', verses: 60 },
  31: { name_tr: 'Lokmân', verses: 34 },
  32: { name_tr: 'Secde', verses: 30 },
  33: { name_tr: 'Ahzâb', verses: 73 },
  34: { name_tr: 'Sebe\'', verses: 54 },
  35: { name_tr: 'Fâtır', verses: 45 },
  36: { name_tr: 'Yâsîn', verses: 83 },
  37: { name_tr: 'Sâffât', verses: 182 },
  38: { name_tr: 'Sâd', verses: 88 },
  39: { name_tr: 'Zümer', verses: 75 },
  40: { name_tr: 'Mü\'min', verses: 85 },
  41: { name_tr: 'Fussilet', verses: 54 },
  42: { name_tr: 'Şûrâ', verses: 53 },
  43: { name_tr: 'Zuhruf', verses: 89 },
  44: { name_tr: 'Duhân', verses: 59 },
  45: { name_tr: 'Câsiye', verses: 37 },
  46: { name_tr: 'Ahkâf', verses: 35 },
  47: { name_tr: 'Muhammed', verses: 38 },
  48: { name_tr: 'Fetih', verses: 29 },
  49: { name_tr: 'Hucurât', verses: 18 },
  50: { name_tr: 'Kâf', verses: 45 },
  51: { name_tr: 'Zâriyât', verses: 60 },
  52: { name_tr: 'Tûr', verses: 49 },
  53: { name_tr: 'Necm', verses: 62 },
  54: { name_tr: 'Kamer', verses: 55 },
  55: { name_tr: 'Rahmân', verses: 78 },
  56: { name_tr: 'Vâkıa', verses: 96 },
  57: { name_tr: 'Hadîd', verses: 29 },
  58: { name_tr: 'Mücâdele', verses: 22 },
  59: { name_tr: 'Haşr', verses: 24 },
  60: { name_tr: 'Mümtehine', verses: 13 },
  61: { name_tr: 'Saff', verses: 14 },
  62: { name_tr: 'Cum\'a', verses: 11 },
  63: { name_tr: 'Münâfikûn', verses: 11 },
  64: { name_tr: 'Teğâbün', verses: 18 },
  65: { name_tr: 'Talâk', verses: 12 },
  66: { name_tr: 'Tahrîm', verses: 12 },
  67: { name_tr: 'Mülk', verses: 30 },
  68: { name_tr: 'Kalem', verses: 52 },
  69: { name_tr: 'Hâkka', verses: 52 },
  70: { name_tr: 'Meâric', verses: 44 },
  71: { name_tr: 'Nûh', verses: 28 },
  72: { name_tr: 'Cin', verses: 28 },
  73: { name_tr: 'Müzzemmil', verses: 20 },
  74: { name_tr: 'Müddessir', verses: 56 },
  75: { name_tr: 'Kıyâme', verses: 40 },
  76: { name_tr: 'İnsân', verses: 31 },
  77: { name_tr: 'Mürselât', verses: 50 },
  78: { name_tr: 'Nebe\'', verses: 40 },
  79: { name_tr: 'Nâziât', verses: 46 },
  80: { name_tr: 'Abese', verses: 42 },
  81: { name_tr: 'Tekvîr', verses: 29 },
  82: { name_tr: 'İnfitâr', verses: 19 },
  83: { name_tr: 'Mutaffifîn', verses: 36 },
  84: { name_tr: 'İnşikâk', verses: 25 },
  85: { name_tr: 'Bürûc', verses: 22 },
  86: { name_tr: 'Târık', verses: 17 },
  87: { name_tr: 'A\'lâ', verses: 19 },
  88: { name_tr: 'Gâşiye', verses: 26 },
  89: { name_tr: 'Fecr', verses: 30 },
  90: { name_tr: 'Beled', verses: 20 },
  91: { name_tr: 'Şems', verses: 15 },
  92: { name_tr: 'Leyl', verses: 21 },
  93: { name_tr: 'Duhâ', verses: 11 },
  94: { name_tr: 'İnşirâh', verses: 8 },
  95: { name_tr: 'Tîn', verses: 8 },
  96: { name_tr: 'Alak', verses: 19 },
  97: { name_tr: 'Kadir', verses: 5 },
  98: { name_tr: 'Beyyine', verses: 8 },
  99: { name_tr: 'Zilzâl', verses: 8 },
  100: { name_tr: 'Âdiyât', verses: 11 },
  101: { name_tr: 'Kâria', verses: 11 },
  102: { name_tr: 'Tekâsür', verses: 8 },
  103: { name_tr: 'Asr', verses: 3 },
  104: { name_tr: 'Hümeze', verses: 9 },
  105: { name_tr: 'Fîl', verses: 5 },
  106: { name_tr: 'Kureyş', verses: 4 },
  107: { name_tr: 'Mâûn', verses: 7 },
  108: { name_tr: 'Kevser', verses: 3 },
  109: { name_tr: 'Kâfirûn', verses: 6 },
  110: { name_tr: 'Nasr', verses: 3 },
  111: { name_tr: 'Tebbet', verses: 5 },
  112: { name_tr: 'İhlâs', verses: 4 },
  113: { name_tr: 'Felak', verses: 5 },
  114: { name_tr: 'Nâs', verses: 6 },
};

// Helper function to delay between requests (rate limiting)
const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

// Fetch with retry logic
async function fetchWithRetry(url: string, retries = 3): Promise<any> {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      return await response.json();
    } catch (error) {
      console.log(`  ⚠️ Retry ${i + 1}/${retries} for ${url}`);
      if (i === retries - 1) throw error;
      await delay(2000 * (i + 1)); // Exponential backoff
    }
  }
}

// Fetch Arabic text for a surah
async function fetchArabicVerses(surahNumber: number): Promise<Map<number, string>> {
  const url = `${API_BASE}/quran/verses/uthmani?chapter_number=${surahNumber}`;
  const data = await fetchWithRetry(url);
  
  const verses = new Map<number, string>();
  for (const verse of data.verses) {
    const ayahNumber = verse.verse_key.split(':')[1];
    verses.set(parseInt(ayahNumber), verse.text_uthmani);
  }
  return verses;
}

// Fetch Turkish translation for a surah
async function fetchTurkishTranslation(surahNumber: number): Promise<Map<number, string>> {
  const url = `${API_BASE}/quran/translations/${TURKISH_TRANSLATION_ID}?chapter_number=${surahNumber}`;
  const data = await fetchWithRetry(url);
  
  const translations = new Map<number, string>();
  
  // Translations are returned in order (verse 1, 2, 3, etc.)
  let ayahNumber = 1;
  for (const translation of data.translations) {
    // Clean HTML tags from translation
    const cleanText = translation.text
      .replace(/<[^>]*>/g, '') // Remove HTML tags
      .replace(/\s+/g, ' ')    // Normalize whitespace
      .trim();
    translations.set(ayahNumber, cleanText);
    ayahNumber++;
  }
  return translations;
}

// Import a single surah
async function importSurah(surahNumber: number): Promise<number> {
  const surahInfo = SURAH_INFO[surahNumber];
  console.log(`\n📖 Importing Surah ${surahNumber}: ${surahInfo.name_tr} (${surahInfo.verses} verses)`);
  
  // Fetch Arabic and Turkish in parallel
  const [arabicVerses, turkishTranslations] = await Promise.all([
    fetchArabicVerses(surahNumber),
    fetchTurkishTranslation(surahNumber),
  ]);
  
  let importedCount = 0;
  
  for (let ayah = 1; ayah <= surahInfo.verses; ayah++) {
    const arabic = arabicVerses.get(ayah);
    const turkish = turkishTranslations.get(ayah);
    
    if (!arabic) {
      console.log(`  ⚠️ Missing Arabic for ${surahNumber}:${ayah}`);
      continue;
    }
    
    try {
      await prisma.quranVerse.upsert({
        where: {
          surah_ayah: {
            surah: surahNumber,
            ayah: ayah,
          },
        },
        update: {
          text_ar: arabic,
          text_tr: turkish || '',
          surah_name: surahInfo.name_tr,
        },
        create: {
          surah: surahNumber,
          ayah: ayah,
          text_ar: arabic,
          text_tr: turkish || '',
          surah_name: surahInfo.name_tr,
        },
      });
      importedCount++;
    } catch (error) {
      console.log(`  ❌ Error importing ${surahNumber}:${ayah}:`, error);
    }
  }
  
  console.log(`  ✅ Imported ${importedCount}/${surahInfo.verses} verses`);
  return importedCount;
}

// Main import function
async function main() {
  console.log('🕌 Starting Full Quran Import');
  console.log('================================\n');
  console.log('Source: Quran.com API v4');
  console.log('Translation: Diyanet Vakfı Meali (Turkish)');
  console.log('Total verses to import: 6,236\n');
  
  const startTime = Date.now();
  let totalImported = 0;
  let failedSurahs: number[] = [];
  
  // Import all 114 surahs
  for (let surah = 1; surah <= 114; surah++) {
    try {
      const count = await importSurah(surah);
      totalImported += count;
      
      // Rate limiting - wait between surahs
      await delay(500);
      
      // Progress update every 10 surahs
      if (surah % 10 === 0) {
        const progress = ((surah / 114) * 100).toFixed(1);
        console.log(`\n📊 Progress: ${progress}% (${surah}/114 surahs, ${totalImported} verses)`);
      }
    } catch (error) {
      console.log(`\n❌ Failed to import Surah ${surah}:`, error);
      failedSurahs.push(surah);
    }
  }
  
  const duration = ((Date.now() - startTime) / 1000 / 60).toFixed(1);
  
  console.log('\n================================');
  console.log('🎉 Import Complete!');
  console.log('================================');
  console.log(`✅ Total verses imported: ${totalImported}`);
  console.log(`⏱️ Duration: ${duration} minutes`);
  
  if (failedSurahs.length > 0) {
    console.log(`\n⚠️ Failed surahs (${failedSurahs.length}):`, failedSurahs.join(', '));
    console.log('Run the script again to retry failed surahs.');
  }
  
  // Verify final count
  const dbCount = await prisma.quranVerse.count();
  const coverage = ((dbCount / 6236) * 100).toFixed(1);
  console.log(`\n📊 Database now contains: ${dbCount} verses (${coverage}% coverage)`);
}

main()
  .catch((e) => {
    console.error('Fatal error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });


