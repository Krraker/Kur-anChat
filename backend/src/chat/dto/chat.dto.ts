import { IsString, IsOptional, IsUUID } from 'class-validator';

export class SendMessageDto {
  @IsString()
  message: string;

  @IsOptional()
  @IsUUID()
  conversationId?: string;

  @IsOptional()
  @IsString()
  userId?: string;
}

export class QuranVerseDto {
  id: number;
  surah: number;
  surah_name?: string;
  ayah: number;
  text_ar: string;
  text_tr: string;
}

export class ChatResponseDto {
  conversationId: string;
  response: {
    summary: string;
    verses: QuranVerseDto[];
    disclaimer: string;
  };
}


