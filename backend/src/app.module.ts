import { Module } from '@nestjs/common';
import { ChatModule } from './chat/chat.module';
import { PrismaModule } from './prisma/prisma.module';
import { AudioModule } from './audio/audio.module';

@Module({
  imports: [PrismaModule, ChatModule, AudioModule],
})
export class AppModule {}


