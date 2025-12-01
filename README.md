# Ayet Rehberi (Quran Chat Assistant)

A full-stack application that allows users to ask questions in natural language and receive answers based on Quranic verses.

## 🏗️ Architecture

- **Frontend**: 
  - Web: Next.js 14 + TypeScript + Tailwind CSS
  - Mobile: Flutter + Dart (iOS & Android)
- **Backend**: NestJS + TypeScript + Express
- **Database**: PostgreSQL + Prisma ORM
- **API**: REST

## 📋 Features

- WhatsApp-style chat interface
- Natural language question processing
- Relevant verse retrieval from Quran database
- AI-generated summaries (stub implementation ready for integration)
- Conversation history persistence
- Multi-lingual support (Arabic & Turkish)

## 🗂️ Project Structure

```
ayet-rehberi/
├── backend/                 # NestJS backend application
│   ├── src/
│   │   ├── chat/           # Chat module (endpoints, services)
│   │   ├── prisma/         # Prisma service
│   │   └── main.ts         # Entry point
│   ├── prisma/
│   │   ├── schema.prisma   # Database schema
│   │   └── seed.ts         # Database seeding
│   ├── .env.example
│   └── package.json
├── frontend/               # Next.js web application
│   ├── src/
│   │   ├── app/           # App router pages
│   │   ├── components/    # React components
│   │   ├── services/      # API service layer
│   │   └── types/         # TypeScript types
│   ├── .env.local.example
│   └── package.json
├── mobile/                 # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart      # App entry point
│   │   ├── models/        # Data models
│   │   ├── providers/     # State management
│   │   ├── screens/       # UI screens
│   │   ├── services/      # API services
│   │   └── widgets/       # UI components
│   └── pubspec.yaml       # Flutter dependencies
├── FLUTTER_SETUP.md        # Flutter setup guide
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- Node.js 18+ 
- PostgreSQL 14+
- npm or yarn

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your database credentials
```

4. Run database migrations:
```bash
npx prisma migrate dev
```

5. Seed the database with Quran verses:
```bash
npm run seed
```

6. Start the development server:
```bash
npm run start:dev
```

Backend will run on `http://localhost:3001`

### Frontend Setup

1. Navigate to frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp .env.local.example .env.local
# Edit .env.local with backend API URL
```

4. Start the development server:
```bash
npm run dev
```

Frontend will run on `http://localhost:3000`

### Mobile Setup (Flutter)

1. Navigate to mobile directory:
```bash
cd mobile
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Configure backend URL in `lib/services/api_service.dart`:
   - iOS Simulator: `http://localhost:3001/api`
   - Android Emulator: `http://10.0.2.2:3001/api`
   - Physical device: Use your computer's IP address

4. Run the app:
```bash
flutter run
```

**Note:** See [FLUTTER_SETUP.md](FLUTTER_SETUP.md) for detailed Flutter installation and setup.

Mobile app will run on connected iOS/Android device or simulator

## 📊 Database Schema

### Tables

#### quran_verses
- `id`: Primary key
- `surah`: Surah number (1-114)
- `ayah`: Ayah number within surah
- `text_ar`: Arabic text
- `text_tr`: Turkish translation
- `created_at`, `updated_at`: Timestamps

#### conversations
- `id`: Primary key (UUID)
- `user_id`: User identifier
- `title`: Conversation title
- `created_at`, `updated_at`: Timestamps

#### messages
- `id`: Primary key (UUID)
- `conversation_id`: Foreign key to conversations
- `sender`: 'user' | 'assistant'
- `content`: JSONB field containing message data
- `created_at`: Timestamp

## 🔌 API Endpoints

### POST /chat
Send a message and receive a response with relevant verses.

**Request:**
```json
{
  "message": "What does Quran say about patience?",
  "conversationId": "optional-uuid"
}
```

**Response:**
```json
{
  "conversationId": "uuid",
  "response": {
    "summary": "AI-generated summary based on verses",
    "verses": [
      {
        "id": 1,
        "surah": 2,
        "ayah": 153,
        "text_ar": "يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ",
        "text_tr": "Ey iman edenler! Sabır ve namazla Allah'tan yardım isteyin."
      }
    ],
    "disclaimer": "Bu yanıt Kuran ayetlerine dayanmaktadır. Daha detaylı bilgi için İslam alimlerine danışabilirsiniz."
  }
}
```

### GET /conversations
Get all conversations for a user.

### GET /conversations/:id
Get a specific conversation with all messages.

## 🔧 Configuration

### Backend Environment Variables

```env
DATABASE_URL="postgresql://user:password@localhost:5432/ayet_rehberi"
PORT=3001
CORS_ORIGIN=http://localhost:3000
```

### Frontend Environment Variables

```env
NEXT_PUBLIC_API_URL=http://localhost:3001
```

## 🤖 AI Integration (Coming Soon)

The `generateSummary()` function in the backend is currently a stub. To integrate AI:

1. Choose an AI provider (OpenAI, Anthropic, etc.)
2. Add API credentials to `.env`
3. Implement the summary generation logic in `src/chat/chat.service.ts`

Example integration points:
- Natural language understanding for query interpretation
- Semantic search for verse retrieval
- Summary generation based on retrieved verses

## 🎨 UI Features

- **WhatsApp-style Chat Interface**: Familiar, intuitive messaging experience
- **Real-time Message Display**: Instant feedback for user interactions
- **Verse Cards**: Beautiful display of Arabic text with translations
- **Conversation History**: Persistent chat history across sessions
- **Responsive Design**: Works on desktop and mobile devices

## 📝 Development Notes

### Adding Quran Data

The initial setup includes a seed file structure. To populate with complete Quran data:

1. Obtain a Quran dataset (JSON format recommended)
2. Update `backend/prisma/seed.ts` with your data source
3. Run `npm run seed`

### Extending the API

To add new endpoints:
1. Create new controllers in `backend/src/chat/`
2. Add service methods in `chat.service.ts`
3. Update the Prisma schema if needed
4. Run migrations: `npx prisma migrate dev`

## 🧪 Testing

```bash
# Backend tests
cd backend
npm run test

# Frontend tests
cd frontend
npm run test
```

## 📦 Deployment

### Backend Deployment (Railway/Heroku/Render)

1. Set up PostgreSQL database
2. Set environment variables
3. Run migrations
4. Deploy application

### Frontend Deployment (Vercel)

1. Connect GitHub repository
2. Set environment variables
3. Deploy automatically on push

## 🤝 Contributing

This is a private project template. Feel free to extend and customize for your needs.

## 📄 License

MIT

## 🙏 Credits

- Quran text sources: [Add your data source]
- Built with love for the Muslim community

---

**Note**: This application is designed to help users explore Quranic teachings. Always consult qualified Islamic scholars for religious guidance.

