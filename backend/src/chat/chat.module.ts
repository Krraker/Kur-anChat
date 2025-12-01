import { Module } from '@nestjs/common';
import { ChatController } from './chat.controller';
import { ChatService } from './chat.service';
import { ConversationsController } from './conversations.controller';
import { OpenAIService } from './openai.service';

@Module({
  controllers: [ChatController, ConversationsController],
  providers: [ChatService, OpenAIService],
})
export class ChatModule {}


