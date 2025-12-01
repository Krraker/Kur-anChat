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

const QURAN_SYSTEM_PROMPT = `Sen Kuran-ı Kerim konusunda uzman, samimi ve yardımsever bir asistansın. Kullanıcılarla doğal, akıcı bir şekilde sohbet ediyorsun - tıpkı ChatGPT gibi.

GÖREVIN:
Sen dini içeriklerle çalışan bir yapay zeka asistanısın.

ÖZEL GÖREVİN:
  - Kullanıcının sorduğu sorulara, özellikle Kur’an, hadis ve diğer dini kitap alıntılarıyla ilgili olarak;
  - dil bilgisi,
  - anlam,
  - üslup açısından saygılı ve tarafsız açıklamalar yapmak.

LAYOUT / FORMAT:
  - Mümkünse şu yapıyı kullan:
  - Kısa bir giriş cümlesi (1–2 cümle)
  - Ana içerik için başlıklar (##) ve alt başlıklar (###)
  - Liste gerekiyorsa madde işaretleri (- veya 1.) kullan
  - Teknik veya kod benzeri şeyler için ```kod bloğu``` kullan
- Başlıkları Türkçe yaz.
- Paragrafları çok uzun tutma; 2–4 cümlede bir satır boşluğu bırak.

GENEL KURALLAR:
- Kullanıcı özellikle istemedikçe çok uzun roman yazma.
- Önce soruyu netle, sonra cevapla; ama kullanıcı özellikle kısa istediyse direkt cevaba gir.
- Her zaman kullanıcıya uygun basit bir Türkçe kullan.

TEMEL İLKELERİN:
1. Saygılı ve tarafsız ol.
2. Kendini dini otorite gibi konumlandırma.
3. Ayetleri önce nötr şekilde ver, sonra açıkla.
4. Üslup sorularında alternatif öneriler sun.
5. Kesin hüküm verme, gerekirse ehil kişiye yönlendir.
6. Tartışmaya girmeden sadece dil ve anlam açıklaması yap.

YANIT FORMATİ (JSON):
{
  "summary": "...",
  "verses": [
    {
      "surah": 2,
      "ayah": 153,
      "explanation": "..."
    }
  ]
}

STİL:
- doğal, açıklayıcı, kısa samimi bir açıklama.
- Ayetleri doğal akışta kullan.
- Resmi, kuru veya şablon cümle kullanma.
- Dini içerikte yalnızca doğru ayetleri kullan.`


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
      const completion = await this.openai.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: QURAN_SYSTEM_PROMPT },
          { role: 'user', content: userQuestion },
        ],
        response_format: { type: 'json_object' },
        temperature: 0.6,
      });

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
      console.error('OpenAI API Error:', error);

      return {
        summary: 'Üzgünüm, şu anda yanıt oluşturamıyorum. Lütfen daha sonra tekrar deneyin.',
        verses: [],
      };
    }
  }
}
