import { Controller, Get, Param, Query } from '@nestjs/common';
import { ChatService } from './chat.service';

@Controller('conversations')
export class ConversationsController {
  constructor(private readonly chatService: ChatService) {}

  @Get()
  async getConversations(@Query('userId') userId: string = 'demo-user') {
    return this.chatService.getConversations(userId);
  }

  @Get(':id')
  async getConversation(@Param('id') id: string) {
    return this.chatService.getConversationById(id);
  }
}


