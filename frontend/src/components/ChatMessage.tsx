'use client';

import type { Message, AssistantMessageContent, UserMessageContent } from '@/types';

interface ChatMessageProps {
  message: Message;
}

export default function ChatMessage({ message }: ChatMessageProps) {
  const isUser = message.sender === 'user';

  if (isUser) {
    const content = message.content as UserMessageContent;
    return (
      <div className="flex justify-end message-enter">
        <div 
          className="rounded-2xl rounded-tr-sm px-4 py-3 max-w-md shadow-md border"
          style={{ 
            backgroundColor: '#FFF4E0',
            borderColor: '#E8D4B0',
            color: '#4A3E2A'
          }}
        >
          <p className="text-sm leading-relaxed">{content.text}</p>
        </div>
      </div>
    );
  }

  const content = message.content as AssistantMessageContent;

  return (
    <div className="flex justify-start message-enter">
      <div 
        className="rounded-2xl rounded-tl-sm px-4 py-3 max-w-2xl shadow-md border"
        style={{ 
          backgroundColor: '#FFFBF0',
          borderColor: '#E8DCC8'
        }}
      >
        {/* Summary */}
        <div className="mb-4">
          <p className="text-sm leading-relaxed tracking-wide" style={{ color: '#3E3228' }}>
            {content.summary}
          </p>
        </div>

        {/* Verses */}
        {content.verses && content.verses.length > 0 && (
          <div className="space-y-3">
            {content.verses.map((verse, index) => (
              <div
                key={verse.id}
                className="border-l-4 border-primary-500 bg-[#FFFBF0] rounded-r-lg p-3.5 shadow-sm"
              >
                <div className="flex items-center gap-2 mb-3">
                  <span className="text-xs font-semibold text-primary-700 bg-primary-100 px-2.5 py-1 rounded">
                    {verse.surah_name ? `${verse.surah_name} Suresi, ${verse.ayah}. Ayet` : `${verse.surah}:${verse.ayah}`}
                  </span>
                </div>
                <p className="text-right text-lg leading-loose mb-3 font-arabic font-semibold tracking-wide" dir="rtl" style={{ textShadow: '0 1px 2px rgba(0,0,0,0.05)' }}>
                  {verse.text_ar}
                </p>
                <p className="text-sm text-gray-600 leading-relaxed italic tracking-wide">
                  {verse.text_tr}
                </p>
              </div>
            ))}
          </div>
        )}

        {/* Disclaimer */}
        {content.disclaimer && (
          <div className="mt-4 pt-3" style={{ borderTop: '1px solid #E8DCC8' }}>
            <p className="text-xs italic leading-relaxed tracking-wide" style={{ color: '#6B5D4F' }}>
              {content.disclaimer}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}


