import {
  Controller,
  Get,
  Param,
  Query,
  Res,
  HttpException,
  HttpStatus,
  Header,
} from '@nestjs/common';
import { Response } from 'express';
import { AudioService } from './audio.service';

@Controller('audio')
export class AudioController {
  constructor(private readonly audioService: AudioService) {}

  @Get('verse/:surah/:ayah')
  @Header('Content-Type', 'audio/mpeg')
  @Header('Cache-Control', 'public, max-age=86400')
  async getVerseAudio(
    @Param('surah') surah: string,
    @Param('ayah') ayah: string,
    @Query('voice') voiceId?: string,
    @Res() res?: Response,
  ) {
    try {
      if (!this.audioService.isConfigured()) {
        throw new HttpException('Audio service not configured', HttpStatus.SERVICE_UNAVAILABLE);
      }

      const surahNum = parseInt(surah, 10);
      const ayahNum = parseInt(ayah, 10);

      if (isNaN(surahNum) || isNaN(ayahNum)) {
        throw new HttpException('Invalid surah or ayah number', HttpStatus.BAD_REQUEST);
      }

      const audioBuffer = await this.audioService.generateVerseAudio(surahNum, ayahNum, voiceId);
      res.set('Content-Length', audioBuffer.length.toString());
      res.send(audioBuffer);
    } catch (error) {
      if (error instanceof HttpException) throw error;
      if (error.message?.includes('not found')) {
        throw new HttpException(error.message, HttpStatus.NOT_FOUND);
      }
      throw new HttpException(`Failed to generate audio: ${error.message}`, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @Get('status')
  async getStatus() {
    const isConfigured = this.audioService.isConfigured();
    if (!isConfigured) {
      return { status: 'not_configured', message: 'ElevenLabs API key not set' };
    }
    const usage = await this.audioService.getUsageInfo();
    return { status: 'configured', usage };
  }
}
