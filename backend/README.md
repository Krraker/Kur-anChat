# Ayet Rehberi Backend

NestJS backend API for Ayet Rehberi (Quran Chat Assistant)

## Tech Stack

- **Framework**: NestJS
- **Language**: TypeScript
- **Database**: PostgreSQL
- **ORM**: Prisma
- **API**: REST

## Setup

1. Install dependencies:
```bash
npm install
```

2. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your database credentials
```

3. Generate Prisma client:
```bash
npx prisma generate
```

4. Run database migrations:
```bash
npx prisma migrate dev
```

5. Seed the database:
```bash
npm run seed
```

6. Start development server:
```bash
npm run start:dev
```

The API will be available at `http://localhost:3001/api`

## API Endpoints

### POST /api/chat
Send a message and receive a response with relevant Quran verses.

**Request Body:**
```json
{
  "message": "What does Quran say about patience?",
  "conversationId": "optional-uuid",
  "userId": "demo-user"
}
```

**Response:**
```json
{
  "conversationId": "uuid",
  "response": {
    "summary": "AI-generated summary",
    "verses": [...],
    "disclaimer": "..."
  }
}
```

### GET /api/conversations
Get all conversations for a user.

**Query Parameters:**
- `userId` (optional): User identifier, defaults to "demo-user"

### GET /api/conversations/:id
Get a specific conversation with all messages.

## Project Structure

```
backend/
├── prisma/
│   ├── schema.prisma       # Database schema
│   ├── seed.ts             # Database seeding script
│   └── migrations/         # Migration files
├── src/
│   ├── chat/
│   │   ├── chat.controller.ts
│   │   ├── chat.service.ts
│   │   ├── conversations.controller.ts
│   │   ├── chat.module.ts
│   │   └── dto/
│   ├── prisma/
│   │   ├── prisma.service.ts
│   │   └── prisma.module.ts
│   ├── app.module.ts
│   └── main.ts             # Application entry point
├── .env.example
├── package.json
└── tsconfig.json
```

## Database Schema

### Tables

- **quran_verses**: Stores Quran verses with Arabic text and Turkish translation
- **conversations**: Stores user conversations
- **messages**: Stores individual messages (user and assistant)

## Development

```bash
# Development mode with hot reload
npm run start:dev

# Build for production
npm run build

# Run production build
npm run start:prod

# Run tests
npm run test

# Lint code
npm run lint
```

## Database Management

```bash
# Open Prisma Studio (GUI for database)
npx prisma studio

# Create a new migration
npx prisma migrate dev --name migration_name

# Reset database (WARNING: deletes all data)
npx prisma migrate reset

# Seed database
npm run seed
```

## AI Integration

The `generateSummary()` method in `chat.service.ts` is currently a stub. To integrate AI:

1. Add your AI provider credentials to `.env`:
```env
OPENAI_API_KEY=your_key_here
```

2. Install the AI SDK:
```bash
npm install openai
```

3. Implement the AI logic in `src/chat/chat.service.ts`

Example OpenAI integration:
```typescript
import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

private async generateSummary(message: string, verses: any[]): Promise<string> {
  const prompt = `Based on these Quran verses: ${JSON.stringify(verses)}, 
                  answer this question: ${message}`;
  
  const response = await openai.chat.completions.create({
    model: 'gpt-4',
    messages: [{ role: 'user', content: prompt }],
  });
  
  return response.choices[0].message.content;
}
```

## Extending Verse Retrieval

Current implementation uses simple keyword matching. For better results, consider:

1. **Semantic Search**: Use vector embeddings (OpenAI embeddings + pgvector)
2. **Full-Text Search**: Implement PostgreSQL full-text search
3. **Topic Tagging**: Add tags/categories to verses
4. **Arabic NLP**: Use Arabic NLP libraries for better keyword extraction

## Production Checklist

- [ ] Set strong DATABASE_URL
- [ ] Set appropriate CORS_ORIGIN
- [ ] Enable rate limiting
- [ ] Add authentication/authorization
- [ ] Set up logging and monitoring
- [ ] Configure error handling
- [ ] Add request validation
- [ ] Set up CI/CD pipeline
- [ ] Configure database backups

## License

MIT


