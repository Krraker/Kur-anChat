import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface ElevenLabsVoice {
  voice_id: string;
  name: string;
  category: string;
}

@Injectable()
export class AudioService {
  private readonly logger = new Logger(AudioService.name);
  private readonly apiKey: string;
  private readonly baseUrl = 'https://api.elevenlabs.io/v1';
  
  // Default Turkish voice - "Yunus - Charismatic Turkish Male"
  private readonly defaultVoiceId: string = 'Q5n6GDIjpN0pLOlycRFT';
  
  // Voice settings for natural Quran translation reading
  // Optimized for "Yunus - Charismatic Turkish Male" voice
  private readonly voiceSettings = {
    stability: 0.48,        // 48% - More expressive, natural variation
    similarity_boost: 0.80, // 80% - High similarity to original voice
    style: 0.03,           // 3% - Subtle style, calm reading
    use_speaker_boost: true,
  };

  constructor(private readonly prisma: PrismaService) {
    this.apiKey = process.env.ELEVENLABS_API_KEY || '';
    if (process.env.ELEVENLABS_VOICE_ID) {
      this.defaultVoiceId = process.env.ELEVENLABS_VOICE_ID;
    }
    
    if (!this.apiKey) {
      this.logger.warn('ELEVENLABS_API_KEY not set - audio generation will be disabled');
    }
  }

  /**
   * Get available Turkish voices from ElevenLabs
   */
  async getAvailableVoices(): Promise<ElevenLabsVoice[]> {
    if (!this.apiKey) {
      throw new Error('ElevenLabs API key not configured');
    }

    try {
      const response = await fetch(`${this.baseUrl}/voices`, {
        headers: {
          'xi-api-key': this.apiKey,
        },
      });

      if (!response.ok) {
        throw new Error(`Failed to fetch voices: ${response.statusText}`);
      }

      const data = await response.json();
      return data.voices.map((voice: any) => ({
        voice_id: voice.voice_id,
        name: voice.name,
        category: voice.category || 'generated',
      }));
    } catch (error) {
      this.logger.error('Error fetching voices:', error);
      throw error;
    }
  }

  /**
   * Generate audio for a specific verse
   */
  async generateVerseAudio(
    surah: number,
    ayah: number,
    voiceId?: string,
  ): Promise<Buffer> {
    if (!this.apiKey) {
      throw new Error('ElevenLabs API key not configured');
    }

    const verse = await this.prisma.quranVerse.findUnique({
      where: {
        surah_ayah: { surah, ayah },
      },
    });

    if (!verse) {
      throw new Error(`Verse not found: ${surah}:${ayah}`);
    }

    return this.textToSpeech(verse.text_tr, voiceId);
  }

  /**
   * Convert text to speech using ElevenLabs
   */
  async textToSpeech(text: string, voiceId?: string): Promise<Buffer> {
    if (!this.apiKey) {
      throw new Error('ElevenLabs API key not configured');
    }

    const selectedVoiceId = voiceId || this.defaultVoiceId;

    try {
      const response = await fetch(
        `${this.baseUrl}/text-to-speech/${selectedVoiceId}/stream`,
        {
          method: 'POST',
          headers: {
            'Accept': 'audio/mpeg',
            'Content-Type': 'application/json',
            'xi-api-key': this.apiKey,
          },
          body: JSON.stringify({
            text,
            model_id: 'eleven_multilingual_v2',
            voice_settings: this.voiceSettings,
            output_format: 'mp3_44100_128',
          }),
        },
      );

      if (!response.ok) {
        const errorText = await response.text();
        this.logger.error(`ElevenLabs API error: ${response.status} - ${errorText}`);
        throw new Error(`ElevenLabs API error: ${response.statusText}`);
      }

      const arrayBuffer = await response.arrayBuffer();
      return Buffer.from(arrayBuffer);
    } catch (error) {
      this.logger.error('Error generating speech:', error);
      throw error;
    }
  }

  /**
   * Get verse text for audio generation
   */
  async getVerseText(surah: number, ayah: number): Promise<string | null> {
    const verse = await this.prisma.quranVerse.findUnique({
      where: {
        surah_ayah: { surah, ayah },
      },
    });

    return verse?.text_tr || null;
  }

  /**
   * Get all verses for a surah
   */
  async getSurahVerses(surah: number): Promise<{ ayah: number; text_tr: string; text_ar: string }[]> {
    const verses = await this.prisma.quranVerse.findMany({
      where: { surah },
      orderBy: { ayah: 'asc' },
      select: {
        ayah: true,
        text_tr: true,
        text_ar: true,
      },
    });

    return verses;
  }

  /**
   * Check if ElevenLabs is configured
   */
  isConfigured(): boolean {
    return !!this.apiKey;
  }

  /**
   * Get current API usage/quota
   */
  async getUsageInfo(): Promise<{ character_count: number; character_limit: number } | null> {
    if (!this.apiKey) {
      return null;
    }

    try {
      const response = await fetch(`${this.baseUrl}/user/subscription`, {
        headers: {
          'xi-api-key': this.apiKey,
        },
      });

      if (!response.ok) {
        return null;
      }

      const data = await response.json();
      return {
        character_count: data.character_count || 0,
        character_limit: data.character_limit || 0,
      };
    } catch {
      return null;
    }
  }
}
