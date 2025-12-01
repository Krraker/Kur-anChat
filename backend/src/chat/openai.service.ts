import { Injectable } from '@nestjs/common';
import OpenAI from 'openai';

@Injectable()
export class OpenAIService {
  private openai: OpenAI;

  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });
  }

  async askAboutQuran(userQuestion: string): Promise<{
    summary: string;
    verses: Array<{ surah: number; ayah: number; explanation: string }>;
  }> {
    try {
      const completion = await this.openai.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'system',
            content: `Sen bir Kuran-ı Kerim uzmanısın. Kullanıcının sorularına Kuran ayetlerine dayanarak cevap veriyorsun.

GÖREVIN:
1. Kullanıcının sorusunu anla
2. İlgili Kuran ayetlerini bul (surah ve ayah numaraları ile)
3. Kısa bir özet ve ayetlerin açıklamasını ver

YANIT FORMATI (JSON):
{
  "summary": "Kısa özet açıklama (2-3 cümle)",
  "verses": [
    {
      "surah": 2,
      "ayah": 153,
      "explanation": "Bu ayette sabır ve namazla yardım istenmesi anlatılır"
    }
  ]
}

ÖNEMLİ:
- Sadece gerçek Kuran ayetlerini kullan
- Sure ve ayet numaralarını doğru ver
- Türkçe açıkla
- 2-4 ayet öner
- JSON formatında yanıt ver`,
          },
          {
            role: 'user',
            content: userQuestion,
          },
        ],
        response_format: { type: 'json_object' },
        temperature: 0.7,
      });

      const response = JSON.parse(completion.choices[0].message.content);
      return response;
    } catch (error) {
      console.error('OpenAI API Error:', error);
      // Fallback response
      return {
        summary: 'Üzgünüm, şu anda yanıt oluşturamıyorum. Lütfen daha sonra tekrar deneyin.',
        verses: [],
      };
    }
  }
}

