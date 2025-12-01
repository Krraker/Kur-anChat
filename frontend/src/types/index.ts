export interface QuranVerse {
  id: number;
  surah: number;
  ayah: number;
  text_ar: string;
  text_tr: string;
}

export interface Message {
  id: string;
  sender: 'user' | 'assistant';
  content: UserMessageContent | AssistantMessageContent;
  createdAt: string;
}

export interface UserMessageContent {
  text: string;
}

export interface AssistantMessageContent {
  summary: string;
  verses: QuranVerse[];
  disclaimer: string;
}

export interface Conversation {
  id: string;
  userId: string;
  title: string;
  createdAt: string;
  updatedAt: string;
  messages?: Message[];
}

export interface SendMessageRequest {
  message: string;
  conversationId?: string;
  userId?: string;
}

export interface ChatResponse {
  conversationId: string;
  response: AssistantMessageContent;
}


