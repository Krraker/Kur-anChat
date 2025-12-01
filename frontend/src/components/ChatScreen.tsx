'use client';

import { useState, useEffect, useRef } from 'react';
import { chatApi } from '@/services/api';
import type { Message, AssistantMessageContent, UserMessageContent } from '@/types';
import ChatMessage from './ChatMessage';
import ChatInput from './ChatInput';

export default function ChatScreen() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [conversationId, setConversationId] = useState<string | undefined>();
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = async (text: string) => {
    if (!text.trim()) return;

    // Add user message to UI immediately
    const userMessage: Message = {
      id: Date.now().toString(),
      sender: 'user',
      content: { text },
      createdAt: new Date().toISOString(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setLoading(true);

    try {
      // Add a small delay for better UX (simulating "thinking")
      await new Promise(resolve => setTimeout(resolve, 800));

      // Send to backend
      const response = await chatApi.sendMessage({
        message: text,
        conversationId,
        userId: 'demo-user',
      });

      // Add another small delay before showing the response
      await new Promise(resolve => setTimeout(resolve, 600));

      // Update conversation ID
      if (!conversationId) {
        setConversationId(response.conversationId);
      }

      // Add assistant response
      const assistantMessage: Message = {
        id: (Date.now() + 1).toString(),
        sender: 'assistant',
        content: response.response,
        createdAt: new Date().toISOString(),
      };

      setMessages((prev) => [...prev, assistantMessage]);
    } catch (error) {
      console.error('Error sending message:', error);
      
      // Add error message
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        sender: 'assistant',
        content: {
          summary: 'Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin.',
          verses: [],
          disclaimer: 'Sunucuya bağlanırken bir sorun yaşandı.',
        },
        createdAt: new Date().toISOString(),
      };

      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col h-screen" style={{ backgroundColor: '#FFFDF7' }}>
      {/* Header */}
      <header className="bg-primary-600 text-white shadow-md">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <h1 className="text-2xl font-bold">Ayet Rehberi</h1>
          <p className="text-sm text-primary-100">Kuran ayetlerine dayalı soru-cevap</p>
        </div>
      </header>

      {/* Chat Messages */}
      <div className="flex-1 overflow-y-auto">
        <div className="max-w-4xl mx-auto px-4 py-6 space-y-4">
          {messages.length === 0 && (
            <div className="text-center py-12">
              <div className="text-6xl mb-4">📖</div>
              <h2 className="text-2xl font-semibold text-gray-700 mb-2">
                Hoş Geldiniz
              </h2>
              <p className="text-gray-500">
                Kuran hakkında soru sormaya başlayın
              </p>
              <div className="mt-8 space-y-2">
                <p className="text-sm text-gray-400">Örnek sorular:</p>
                <div className="flex flex-wrap gap-2 justify-center">
                  <button
                    onClick={() => handleSendMessage('Sabır hakkında ne diyor?')}
                    className="px-4 py-2 bg-white rounded-full text-sm text-gray-700 hover:bg-gray-100 shadow-sm"
                  >
                    Sabır hakkında ne diyor?
                  </button>
                  <button
                    onClick={() => handleSendMessage('Namaz neden önemlidir?')}
                    className="px-4 py-2 bg-white rounded-full text-sm text-gray-700 hover:bg-gray-100 shadow-sm"
                  >
                    Namaz neden önemlidir?
                  </button>
                  <button
                    onClick={() => handleSendMessage('Zorluklar hakkında ne söyler?')}
                    className="px-4 py-2 bg-white rounded-full text-sm text-gray-700 hover:bg-gray-100 shadow-sm"
                  >
                    Zorluklar hakkında ne söyler?
                  </button>
                </div>
              </div>
            </div>
          )}

          {messages.map((message) => (
            <ChatMessage key={message.id} message={message} />
          ))}

          {loading && (
            <div className="flex justify-start message-enter">
              <div className="bg-white rounded-2xl px-5 py-4 shadow-md">
                <div className="flex items-center space-x-1.5">
                  <div className="w-2.5 h-2.5 bg-primary-600 rounded-full animate-bounce shadow-sm"></div>
                  <div className="w-2.5 h-2.5 bg-primary-600 rounded-full animate-bounce shadow-sm" style={{ animationDelay: '0.15s' }}></div>
                  <div className="w-2.5 h-2.5 bg-primary-600 rounded-full animate-bounce shadow-sm" style={{ animationDelay: '0.3s' }}></div>
                </div>
              </div>
            </div>
          )}

          <div ref={messagesEndRef} />
        </div>
      </div>

      {/* Chat Input */}
      <ChatInput onSendMessage={handleSendMessage} disabled={loading} />
    </div>
  );
}


