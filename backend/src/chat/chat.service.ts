import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SendMessageDto, ChatResponseDto } from './dto/chat.dto';
import { getSurahName } from './surah-names';
import { OpenAIService } from './openai.service';

@Injectable()
export class ChatService {
  constructor(
    private prisma: PrismaService,
    private openaiService: OpenAIService,
  ) {}

  /**
   * Main method to process user messages with ChatGPT
   */
  async processMessage(dto: SendMessageDto): Promise<ChatResponseDto> {
    const userId = dto.userId || 'demo-user';
    const { message, conversationId } = dto;

    // Step 1: Get or create conversation
    let conversation;
    if (conversationId) {
      conversation = await this.prisma.conversation.findUnique({
        where: { id: conversationId },
      });
    }

    if (!conversation) {
      const title = message.substring(0, 50) + (message.length > 50 ? '...' : '');
      conversation = await this.prisma.conversation.create({
        data: {
          userId,
          title,
        },
      });
    }

    // Step 2: Save user message
    await this.prisma.message.create({
      data: {
        conversationId: conversation.id,
        sender: 'user',
        content: { text: message },
      },
    });

    // Step 3: ChatGPT'den yanıt al
    console.log('🤖 ChatGPT\'ye sorgulanıyor:', message);
    const aiResponse = await this.openaiService.askAboutQuran(message);
    console.log('✅ ChatGPT yanıtı:', aiResponse);

    // Step 4: Veritabanından ayetleri al
    let verses = await this.fetchVersesFromDB(aiResponse.verses);
    console.log(`📚 Veritabanından ${verses.length} ayet bulundu`);

    // Step 5: Fallback - Eğer ayetler yoksa tüm ayetlerden örnek göster
    let summary = aiResponse.summary;
    if (verses.length === 0) {
      console.log('⚠️ Veritabanında ayet bulunamadı, örnek ayetler gösteriliyor');
      verses = await this.prisma.quranVerse.findMany({
        take: 2,
        skip: Math.floor(Math.random() * 6), // Random başlangıç
      });
      summary = `${summary}\n\n💡 Not: Belirtilen ayetler henüz veritabanımıza eklenmemiş. Yakın konuda örnek ayetler gösterilmektedir.`;
    }

    // Step 6: Create response object
    const responseContent = {
      summary,
      verses: verses.map((v) => ({
        id: v.id,
        surah: v.surah,
        surah_name: getSurahName(v.surah),
        ayah: v.ayah,
        text_ar: v.text_ar,
        text_tr: v.text_tr,
      })),
      disclaimer:
        'Bu yanıt ChatGPT ve Kuran ayetlerine dayanmaktadır. Daha detaylı bilgi için İslam alimlerine danışabilirsiniz.',
    };

    // Step 7: Save assistant response
    await this.prisma.message.create({
      data: {
        conversationId: conversation.id,
        sender: 'assistant',
        content: responseContent,
      },
    });

    return {
      conversationId: conversation.id,
      response: responseContent,
    };
  }

  /**
   * ChatGPT'nin önerdiği ayetleri veritabanından getir
   */
  private async fetchVersesFromDB(
    verseRefs: Array<{ surah: number; ayah: number }>,
  ): Promise<any[]> {
    const verses = [];

    for (const ref of verseRefs) {
      try {
        const verse = await this.prisma.quranVerse.findUnique({
          where: {
            surah_ayah: {
              surah: ref.surah,
              ayah: ref.ayah,
            },
          },
        });

        if (verse) {
          verses.push(verse);
        }
      } catch (error) {
        console.log(`⚠️ Ayet bulunamadı: ${ref.surah}:${ref.ayah}`);
      }
    }

    return verses;
  }

  /**
   * Get all conversations for a user
   */
  async getConversations(userId: string) {
    return this.prisma.conversation.findMany({
      where: { userId },
      orderBy: { updatedAt: 'desc' },
      include: {
        messages: {
          take: 1,
          orderBy: { createdAt: 'asc' },
        },
      },
    });
  }

  /**
   * Get a specific conversation with all messages
   */
  async getConversationById(id: string) {
    return this.prisma.conversation.findUnique({
      where: { id },
      include: {
        messages: {
          orderBy: { createdAt: 'asc' },
        },
      },
    });
  }
}
