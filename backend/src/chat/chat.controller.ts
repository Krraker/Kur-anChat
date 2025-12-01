import { Controller, Post, Body } from '@nestjs/common';
import { ChatService } from './chat.service';
import { SendMessageDto, ChatResponseDto } from './dto/chat.dto';

@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post()
  async sendMessage(@Body() sendMessageDto: SendMessageDto): Promise<ChatResponseDto> {
    return this.chatService.processMessage(sendMessageDto);
  }
}


