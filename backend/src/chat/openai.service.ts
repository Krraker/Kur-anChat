import { Injectable } from '@nestjs/common';
import OpenAI from 'openai';

type QuranVerse = {
  surah: number;
  ayah: number;
  explanation: string;
};

type QuranResponse = {
  summary: string;
  verses: QuranVerse[];
};

const QURAN_SYSTEM_PROMPT = `Sen İslam konusunda yardımsever bir asistansın. Kur'an ayetleri, namaz, oruç, abdest gibi ibadetler ve dini sorular hakkında DETAYLI rehberlik ediyorsun.

ÖNEMLI: İbadet soruları (namaz, oruç, abdest, vb.) için MUTLAKA uzun ve detaylı cevap ver. En az 10-12 adım içermeli!

CEVAP YAKLAŞIMI:

İBADET SORULARI: Adım adım, detaylı, pratik açıklama yap
- Hazırlık (3-4 adım)
- Uygulama (8-12 adım minimum)
- Önemli notlar
- İlgili ayetler varsa ekle

KUR'AN SORULARI: Ayetin anlamını açıkla, verses array'inde belirt

ÖRNEK - NAMAZ CEVABI:
{
  "summary": "## Namaz Nasıl Kılınır?\n\nNamaz İslam'ın 5 şartından biridir.\n\n### Hazırlık\n1. Abdest al\n2. Temiz yer, kıbleye dön\n3. Niyet et\n\n### İki Rekat Namaz\n\n**Birinci Rekat:**\n1. Eller bağlı ayakta dur\n2. \"Allahu Ekber\" de\n3. Sübhaneke oku\n4. Fatiha oku\n5. Kısa sure oku\n6. Rükûya git: \"Sübhane Rabbiyel azîm\" (3x)\n7. Doğrul: \"Semiallahu limen hamideh, Rabbena lekelhamd\"\n8. Secde: \"Sübhane Rabbiyel a'lâ\" (3x)\n9. Kısa otur\n10. 2. secde yap\n\n**İkinci Rekat:**\n11. Kalk, Fatiha ve sure oku\n12. Rükû ve secdeler\n13. Otur, Ettehıyyatü oku\n14. Salli-Barik oku\n15. Sağa-sola selam ver\n\n### Rekat Sayıları\n- Sabah: 2, Öğle: 4, İkindi: 4, Akşam: 3, Yatsı: 4\n\nDetaylı bilgi için İslam alimlerine danışın.",
  "verses": [{"surah": 2, "ayah": 45, "explanation": "Namaz ve sabır"}]
}

KURALLAR:
1. İbadet soruları = UZUN cevap (minimum 10 adım)
2. Markdown başlık ve listeler kullan
3. Saygılı ol, otorite gibi davranma
4. Verses boş [] olabilir

JSON FORMAT:
{"summary": "Detaylı markdown", "verses": [{"surah": X, "ayah": Y, "explanation": "..."}]}`


@Injectable()
export class OpenAIService {
  private openai: OpenAI;

  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });
  }

  async askAboutQuran(userQuestion: string): Promise<QuranResponse> {
    try {
      console.log('🔄 OpenAI API call starting...');
      
      // Create a timeout promise (60 seconds for detailed responses)
      const timeoutPromise = new Promise<never>((_, reject) => {
        setTimeout(() => reject(new Error('OpenAI API timeout after 60 seconds')), 60000);
      });

      // Race between API call and timeout
      const completion = await Promise.race([
        this.openai.chat.completions.create({
          model: 'gpt-4o-mini',
          messages: [
            { role: 'system', content: QURAN_SYSTEM_PROMPT },
            { role: 'user', content: userQuestion },
          ],
          response_format: { type: 'json_object' },
          temperature: 0.7,
          max_tokens: 2500, // Balanced for speed and detail
        }),
        timeoutPromise,
      ]);

      console.log('✅ OpenAI API call completed');

      const messageContent = completion?.choices?.[0]?.message?.content;

      if (!messageContent) {
        throw new Error('Empty response from OpenAI');
      }

      const parsed = JSON.parse(messageContent) as QuranResponse;

      // Basit doğrulama
      if (!parsed || typeof parsed.summary !== 'string' || !Array.isArray(parsed.verses)) {
        throw new Error('Invalid response format');
      }

      return parsed;

    } catch (error) {
      console.error('❌ OpenAI API Error:', error);

      return {
        summary: 'Üzgünüm, şu anda yanıt oluşturamıyorum. Lütfen daha sonra tekrar deneyin.',
        verses: [],
      };
    }
  }
}
