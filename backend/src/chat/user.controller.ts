import { Controller, Get, Post, Body, Headers, HttpCode } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Controller('user')
export class UserController {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Register or get existing user by device ID
   */
  @Post('register')
  @HttpCode(200)
  async register(@Body() body: { deviceId: string; name?: string }) {
    const { deviceId, name } = body;

    if (!deviceId) {
      return { error: 'Device ID is required' };
    }

    // Find or create user
    let user = await this.prisma.user.findUnique({
      where: { deviceId },
      include: { progress: true },
    });

    if (!user) {
      user = await this.prisma.user.create({
        data: {
          deviceId,
          name,
          progress: {
            create: {
              level: 1,
              xp: 0,
              streak: 0,
              totalVersesRead: 0,
            },
          },
        },
        include: { progress: true },
      });
      console.log(`✅ New user created: ${user.id}`);
    }

    return {
      id: user.id,
      deviceId: user.deviceId,
      name: user.name,
      language: user.language,
      progress: user.progress,
    };
  }

  /**
   * Get user progress
   */
  @Get('progress')
  async getProgress(@Headers('x-device-id') deviceId: string) {
    if (!deviceId) {
      return { error: 'Device ID header required' };
    }

    const user = await this.prisma.user.findUnique({
      where: { deviceId },
      include: { progress: true },
    });

    if (!user || !user.progress) {
      return {
        lastReadSurah: 1,
        lastReadAyah: 1,
        level: 1,
        xp: 0,
        streak: 0,
        totalVersesRead: 0,
        totalTimeSpent: 0,
        completedSurahs: [],
      };
    }

    return user.progress;
  }

  /**
   * Mark verse as read
   */
  @Post('progress/verse-read')
  @HttpCode(200)
  async markVerseRead(
    @Headers('x-device-id') deviceId: string,
    @Body() body: { surah: number; ayah: number },
  ) {
    if (!deviceId) {
      return { error: 'Device ID header required' };
    }

    const user = await this.prisma.user.findUnique({
      where: { deviceId },
      include: { progress: true },
    });

    if (!user) {
      return { error: 'User not found' };
    }

    // Update or create progress
    const progress = await this.prisma.userProgress.upsert({
      where: { userId: user.id },
      update: {
        lastReadSurah: body.surah,
        lastReadAyah: body.ayah,
        totalVersesRead: { increment: 1 },
        xp: { increment: 5 }, // 5 XP per verse
      },
      create: {
        userId: user.id,
        lastReadSurah: body.surah,
        lastReadAyah: body.ayah,
        totalVersesRead: 1,
        xp: 5,
      },
    });

    // Check for level up
    const newLevel = Math.floor(progress.xp / 100) + 1;
    if (newLevel > progress.level) {
      await this.prisma.userProgress.update({
        where: { id: progress.id },
        data: { level: newLevel },
      });
    }

    return { success: true, progress };
  }

  /**
   * Update streak
   */
  @Post('progress/update-streak')
  @HttpCode(200)
  async updateStreak(@Headers('x-device-id') deviceId: string) {
    if (!deviceId) {
      return { error: 'Device ID header required' };
    }

    const user = await this.prisma.user.findUnique({
      where: { deviceId },
      include: { progress: true },
    });

    if (!user || !user.progress) {
      return { error: 'User not found' };
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const lastActive = new Date(user.progress.lastActiveDate);
    lastActive.setHours(0, 0, 0, 0);

    const diffDays = Math.floor(
      (today.getTime() - lastActive.getTime()) / (1000 * 60 * 60 * 24),
    );

    let newStreak = user.progress.streak;

    if (diffDays === 0) {
      // Already active today, no change
    } else if (diffDays === 1) {
      // Continue streak
      newStreak += 1;
    } else {
      // Streak broken
      newStreak = 1;
    }

    const progress = await this.prisma.userProgress.update({
      where: { id: user.progress.id },
      data: {
        streak: newStreak,
        lastActiveDate: new Date(),
        xp: { increment: 10 }, // 10 XP for daily check-in
      },
    });

    return { success: true, streak: newStreak, progress };
  }

  /**
   * Get user achievements
   */
  @Get('achievements')
  async getAchievements(@Headers('x-device-id') deviceId: string) {
    if (!deviceId) {
      return { error: 'Device ID header required' };
    }

    const user = await this.prisma.user.findUnique({
      where: { deviceId },
      include: { progress: true },
    });

    if (!user || !user.progress) {
      return { achievements: [] };
    }

    const progress = user.progress;
    const achievements = [];

    // Streak achievements
    if (progress.streak >= 7) {
      achievements.push({
        id: 'streak_7',
        title: 'Haftalık Okuyucu',
        description: '7 gün üst üste okudun',
        icon: '🔥',
        earned: true,
      });
    }
    if (progress.streak >= 30) {
      achievements.push({
        id: 'streak_30',
        title: 'Aylık Okuyucu',
        description: '30 gün üst üste okudun',
        icon: '⭐',
        earned: true,
      });
    }

    // Verse achievements
    if (progress.totalVersesRead >= 100) {
      achievements.push({
        id: 'verses_100',
        title: 'Yüz Ayet',
        description: '100 ayet okudun',
        icon: '📖',
        earned: true,
      });
    }
    if (progress.totalVersesRead >= 1000) {
      achievements.push({
        id: 'verses_1000',
        title: 'Bin Ayet',
        description: '1000 ayet okudun',
        icon: '📚',
        earned: true,
      });
    }

    // Level achievements
    if (progress.level >= 5) {
      achievements.push({
        id: 'level_5',
        title: 'Talebe',
        description: 'Seviye 5\'e ulaştın',
        icon: '🎓',
        earned: true,
      });
    }
    if (progress.level >= 10) {
      achievements.push({
        id: 'level_10',
        title: 'Hafız Adayı',
        description: 'Seviye 10\'a ulaştın',
        icon: '🌙',
        earned: true,
      });
    }

    return { achievements };
  }

  /**
   * Update user preferences
   */
  @Post('preferences')
  @HttpCode(200)
  async updatePreferences(
    @Headers('x-device-id') deviceId: string,
    @Body()
    body: { language?: string; mezhep?: string; translation?: string },
  ) {
    if (!deviceId) {
      return { error: 'Device ID header required' };
    }

    const user = await this.prisma.user.update({
      where: { deviceId },
      data: {
        language: body.language,
        selectedMezhep: body.mezhep,
        translation: body.translation,
      },
    });

    return { success: true, user };
  }
}
