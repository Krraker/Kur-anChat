import { Injectable, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SendMessageDto, ChatResponseDto } from './dto/chat.dto';
import { getSurahName } from './surah-names';
import { OpenAIService } from './openai.service';

@Injectable()
export class ChatService {
  // FREE TIER: 3 messages per day
  private readonly FREE_TIER_DAILY_LIMIT = 3;

  constructor(
    private prisma: PrismaService,
    private openaiService: OpenAIService,
  ) {}

  /**
   * Check if user can send a message (free tier limit check)
   */
  async checkMessageLimit(userId: string): Promise<{
    canSend: boolean;
    remainingMessages: number;
    isPremium: boolean;
    resetAt: Date;
  }> {
    // Get or create user
    let user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      // Create user if not exists
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);
      tomorrow.setHours(0, 0, 0, 0); // Midnight

      user = await this.prisma.user.create({
        data: {
          id: userId,
          dailyMessageCount: 0,
          dailyMessageResetAt: tomorrow,
        },
      });
    }

    // Premium users have unlimited messages
    if (user.isPremium) {
      return {
        canSend: true,
        remainingMessages: -1, // -1 means unlimited
        isPremium: true,
        resetAt: user.dailyMessageResetAt,
      };
    }

    // Check if we need to reset the counter (new day)
    const now = new Date();
    const resetAt = new Date(user.dailyMessageResetAt);

    if (now >= resetAt) {
      // Reset counter for new day
      const tomorrow = new Date(now);
      tomorrow.setDate(tomorrow.getDate() + 1);
      tomorrow.setHours(0, 0, 0, 0); // Midnight

      user = await this.prisma.user.update({
        where: { id: userId },
        data: {
          dailyMessageCount: 0,
          dailyMessageResetAt: tomorrow,
        },
      });
    }

    // Check if user has exceeded limit
    const remaining = this.FREE_TIER_DAILY_LIMIT - user.dailyMessageCount;
    const canSend = remaining > 0;

    return {
      canSend,
      remainingMessages: Math.max(0, remaining),
      isPremium: false,
      resetAt: user.dailyMessageResetAt,
    };
  }

  /**
   * Increment user's daily message count
   */
  async incrementMessageCount(userId: string): Promise<void> {
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        dailyMessageCount: {
          increment: 1,
        },
      },
    });
  }

  /**
   * Main method to process user messages with ChatGPT
   */
  async processMessage(dto: SendMessageDto): Promise<ChatResponseDto> {
    const userId = dto.userId || 'demo-user';
    const { message, conversationId } = dto;

    // ⭐ STEP 0: Check message limit BEFORE processing
    const limitCheck = await this.checkMessageLimit(userId);

    if (!limitCheck.canSend) {
      console.log(`🚫 User ${userId} exceeded daily limit`);
      throw new ForbiddenException({
        message: 'Günlük mesaj limitine ulaştınız',
        code: 'MESSAGE_LIMIT_EXCEEDED',
        remainingMessages: 0,
        resetAt: limitCheck.resetAt.toISOString(),
        isPremium: limitCheck.isPremium,
      });
    }

    console.log(
      `✅ User ${userId} can send message (${limitCheck.remainingMessages} remaining)`,
    );

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
        'Daha detaylı bilgi için İslam alimlerine danışabilirsiniz.',
    };

    // Step 7: Save assistant response
    await this.prisma.message.create({
      data: {
        conversationId: conversation.id,
        sender: 'assistant',
        content: responseContent,
      },
    });

    // ⭐ STEP 8: Increment message count (only AFTER successful response)
    await this.incrementMessageCount(userId);

    // ⭐ STEP 9: Get updated limit info to return to client
    const updatedLimit = await this.checkMessageLimit(userId);

    return {
      conversationId: conversation.id,
      response: responseContent,
      // Include usage info in response
      usage: {
        remainingMessages: updatedLimit.remainingMessages,
        isPremium: updatedLimit.isPremium,
        resetAt: updatedLimit.resetAt.toISOString(),
      },
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
