import axios from 'axios';
import type { SendMessageRequest, ChatResponse, Conversation } from '@/types';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const chatApi = {
  // Send a message and get response
  sendMessage: async (data: SendMessageRequest): Promise<ChatResponse> => {
    const response = await api.post<ChatResponse>('/chat', data);
    return response.data;
  },

  // Get all conversations for a user
  getConversations: async (userId: string = 'demo-user'): Promise<Conversation[]> => {
    const response = await api.get<Conversation[]>('/conversations', {
      params: { userId },
    });
    return response.data;
  },

  // Get a specific conversation with all messages
  getConversation: async (conversationId: string): Promise<Conversation> => {
    const response = await api.get<Conversation>(`/conversations/${conversationId}`);
    return response.data;
  },
};


