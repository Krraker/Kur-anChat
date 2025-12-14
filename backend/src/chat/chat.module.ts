import { Module } from '@nestjs/common';
import { ChatController } from './chat.controller';
import { ChatService } from './chat.service';
import { ConversationsController } from './conversations.controller';
import { DailyController } from './daily.controller';
import { QuranController } from './quran.controller';
import { UserController } from './user.controller';
import { TafsirController } from './tafsir.controller';
import { OpenAIService } from './openai.service';

@Module({
  controllers: [
    ChatController,
    ConversationsController,
    DailyController,
    QuranController,
    UserController,
    TafsirController,
  ],
  providers: [ChatService, OpenAIService],
})
export class ChatModule {}


