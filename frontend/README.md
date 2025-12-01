# Ayet Rehberi Frontend

Next.js frontend application for Ayet Rehberi (Quran Chat Assistant)

## Tech Stack

- **Framework**: Next.js 14
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **HTTP Client**: Axios

## Setup

1. Install dependencies:
```bash
npm install
```

2. Set up environment variables:
```bash
cp .env.local.example .env.local
```

Edit `.env.local`:
```env
NEXT_PUBLIC_API_URL=http://localhost:3001/api
```

3. Start development server:
```bash
npm run dev
```

The app will be available at `http://localhost:3000`

## Project Structure

```
frontend/
├── src/
│   ├── app/
│   │   ├── layout.tsx      # Root layout
│   │   ├── page.tsx        # Home page
│   │   └── globals.css     # Global styles
│   ├── components/
│   │   ├── ChatScreen.tsx  # Main chat interface
│   │   ├── ChatMessage.tsx # Message bubble component
│   │   └── ChatInput.tsx   # Input component
│   ├── services/
│   │   └── api.ts          # API service layer
│   └── types/
│       └── index.ts        # TypeScript interfaces
├── .env.local.example
├── next.config.js
├── tailwind.config.ts
└── package.json
```

## Features

### WhatsApp-Style Chat Interface
- Clean, modern design inspired by WhatsApp
- User messages: Right-aligned, primary color
- Assistant messages: Left-aligned, white background
- Smooth animations and transitions

### Verse Display
- Beautiful Arabic text rendering
- Turkish translations
- Surah and Ayah references
- Border accent for easy identification

### User Experience
- Auto-scroll to latest message
- Loading indicators
- Example question suggestions
- Responsive design (mobile-friendly)
- Error handling with user-friendly messages

## Components

### ChatScreen
Main container component that manages:
- Message state
- Conversation state
- API calls
- Message history

### ChatMessage
Displays individual messages:
- User messages: Simple text bubbles
- Assistant messages: Summary + verses + disclaimer

### ChatInput
Input area with:
- Auto-expanding textarea
- Enter to send (Shift+Enter for new line)
- Send button with icon
- Disabled state during loading

## Styling

### Colors
- Primary: Green (#22c55e and variants)
- Background: Gray gradients
- Text: Gray tones
- Cards: White with subtle shadows

### Typography
- Font: Inter (Google Fonts)
- Arabic text: Larger size, right-aligned

### Animations
- Message entry: Slide in from bottom
- Loading: Bouncing dots
- Smooth scrolling

## API Integration

The frontend communicates with the backend via REST API:

```typescript
// Send message
chatApi.sendMessage({
  message: "Your question",
  conversationId: "optional-id",
  userId: "demo-user"
});

// Get conversations
chatApi.getConversations("demo-user");

// Get conversation by ID
chatApi.getConversation("conversation-id");
```

## Development

```bash
# Development mode
npm run dev

# Build for production
npm run build

# Run production build
npm run start

# Lint code
npm run lint
```

## Customization

### Changing Colors
Edit `tailwind.config.ts`:
```typescript
theme: {
  extend: {
    colors: {
      primary: {
        // Your custom color palette
      }
    }
  }
}
```

### Changing Layout
Edit components in `src/components/`:
- `ChatScreen.tsx`: Overall layout
- `ChatMessage.tsx`: Message appearance
- `ChatInput.tsx`: Input area

### Adding Features
Consider adding:
- Conversation history sidebar
- Search within conversations
- Export conversation
- Share verse functionality
- Dark mode toggle
- Multi-language support
- Voice input
- Bookmark verses

## Deployment

### Vercel (Recommended)

1. Push code to GitHub
2. Import project in Vercel
3. Set environment variables:
   - `NEXT_PUBLIC_API_URL`: Your backend URL
4. Deploy

### Other Platforms

The app is a standard Next.js application and can be deployed to:
- Netlify
- AWS Amplify
- Digital Ocean
- Self-hosted with PM2

Build command:
```bash
npm run build
```

Start command:
```bash
npm run start
```

## Environment Variables

- `NEXT_PUBLIC_API_URL`: Backend API URL (must start with NEXT_PUBLIC_ to be accessible in browser)

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Performance

- Code splitting with Next.js
- Image optimization
- Fast page loads
- Responsive design

## Accessibility

- Semantic HTML
- ARIA labels
- Keyboard navigation
- Focus indicators

## Troubleshooting

**Cannot connect to backend:**
- Check NEXT_PUBLIC_API_URL in .env.local
- Verify backend is running
- Check browser console for errors

**Styles not loading:**
```bash
rm -rf .next
npm run build
npm run dev
```

**TypeScript errors:**
```bash
npm install
```

## License

MIT


