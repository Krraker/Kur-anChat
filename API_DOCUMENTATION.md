# API Documentation

Base URL: `http://localhost:3001/api`

## Authentication

Currently, the API uses a simple user ID system. In production, implement proper authentication (JWT, OAuth, etc.).

## Endpoints

### 1. Send Message

Send a user message and receive an AI-generated response with relevant Quran verses.

**Endpoint:** `POST /chat`

**Request Body:**
```json
{
  "message": "string (required)",
  "conversationId": "uuid (optional)",
  "userId": "string (optional, defaults to 'demo-user')"
}
```

**Response:** `200 OK`
```json
{
  "conversationId": "uuid",
  "response": {
    "summary": "string",
    "verses": [
      {
        "id": "number",
        "surah": "number",
        "ayah": "number",
        "text_ar": "string",
        "text_tr": "string"
      }
    ],
    "disclaimer": "string"
  }
}
```

**Example Request:**
```bash
curl -X POST http://localhost:3001/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Sabır hakkında ne diyor Kuran?",
    "userId": "demo-user"
  }'
```

**Example Response:**
```json
{
  "conversationId": "550e8400-e29b-41d4-a716-446655440000",
  "response": {
    "summary": "Kuran-ı Kerim, sabırın önemini vurgular ve sabredenlerin Allah ile birlikte olduğunu belirtir.",
    "verses": [
      {
        "id": 1,
        "surah": 2,
        "ayah": 153,
        "text_ar": "يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ",
        "text_tr": "Ey iman edenler! Sabır ve namazla Allah'tan yardım isteyin."
      }
    ],
    "disclaimer": "Bu yanıt Kuran ayetlerine dayanmaktadır."
  }
}
```

**Error Responses:**

`400 Bad Request` - Invalid request body
```json
{
  "statusCode": 400,
  "message": ["message should not be empty"],
  "error": "Bad Request"
}
```

`500 Internal Server Error` - Server error
```json
{
  "statusCode": 500,
  "message": "Internal server error"
}
```

---

### 2. Get Conversations

Retrieve all conversations for a specific user.

**Endpoint:** `GET /conversations`

**Query Parameters:**
- `userId` (string, optional): User identifier. Defaults to 'demo-user'

**Response:** `200 OK`
```json
[
  {
    "id": "uuid",
    "userId": "string",
    "title": "string",
    "createdAt": "datetime",
    "updatedAt": "datetime",
    "messages": [
      {
        "id": "uuid",
        "sender": "user" | "assistant",
        "content": {},
        "createdAt": "datetime"
      }
    ]
  }
]
```

**Example Request:**
```bash
curl http://localhost:3001/api/conversations?userId=demo-user
```

**Example Response:**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "userId": "demo-user",
    "title": "Sabır hakkında ne diyor Kuran?",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:05:00.000Z",
    "messages": [
      {
        "id": "660e8400-e29b-41d4-a716-446655440001",
        "sender": "user",
        "content": {
          "text": "Sabır hakkında ne diyor Kuran?"
        },
        "createdAt": "2024-01-01T12:00:00.000Z"
      }
    ]
  }
]
```

---

### 3. Get Conversation by ID

Retrieve a specific conversation with all its messages.

**Endpoint:** `GET /conversations/:id`

**Path Parameters:**
- `id` (uuid, required): Conversation ID

**Response:** `200 OK`
```json
{
  "id": "uuid",
  "userId": "string",
  "title": "string",
  "createdAt": "datetime",
  "updatedAt": "datetime",
  "messages": [
    {
      "id": "uuid",
      "conversationId": "uuid",
      "sender": "user" | "assistant",
      "content": {},
      "createdAt": "datetime"
    }
  ]
}
```

**Example Request:**
```bash
curl http://localhost:3001/api/conversations/550e8400-e29b-41d4-a716-446655440000
```

**Error Responses:**

`404 Not Found` - Conversation not found
```json
{
  "statusCode": 404,
  "message": "Conversation not found"
}
```

---

## Data Models

### Message Content Types

#### User Message Content
```typescript
{
  text: string;
}
```

#### Assistant Message Content
```typescript
{
  summary: string;
  verses: QuranVerse[];
  disclaimer: string;
}
```

### QuranVerse
```typescript
{
  id: number;
  surah: number;        // 1-114
  ayah: number;         // Verse number within surah
  text_ar: string;      // Arabic text
  text_tr: string;      // Turkish translation
}
```

### Conversation
```typescript
{
  id: string;           // UUID
  userId: string;
  title: string | null;
  createdAt: string;    // ISO 8601
  updatedAt: string;    // ISO 8601
  messages?: Message[];
}
```

### Message
```typescript
{
  id: string;                    // UUID
  conversationId: string;        // UUID
  sender: 'user' | 'assistant';
  content: UserMessageContent | AssistantMessageContent;
  createdAt: string;             // ISO 8601
}
```

---

## Message Processing Pipeline

When a message is sent to `/chat`, the backend processes it through these steps:

1. **Conversation Management**
   - If `conversationId` provided: Use existing conversation
   - If not provided: Create new conversation

2. **Save User Message**
   - Store the user's message in the database

3. **Intent Detection**
   - Extract keywords from the message
   - Map keywords to topics (sabır, namaz, zorluk, etc.)

4. **Verse Retrieval**
   - Query database for relevant verses based on topics
   - Currently uses keyword matching
   - Future: Semantic search with embeddings

5. **Summary Generation**
   - Generate summary based on verses
   - Currently: Template-based responses
   - Future: AI-powered summaries (OpenAI, Anthropic)

6. **Response Assembly**
   - Combine summary, verses, and disclaimer
   - Save assistant message to database

7. **Return Response**
   - Send complete response to frontend

---

## Error Handling

All endpoints follow standard HTTP status codes:

- `200 OK` - Success
- `400 Bad Request` - Invalid input
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

Error response format:
```json
{
  "statusCode": number,
  "message": string | string[],
  "error": string
}
```

---

## Rate Limiting

Currently not implemented. For production, consider:
- Rate limit per IP address
- Rate limit per user
- Use libraries like `@nestjs/throttler`

---

## CORS Configuration

CORS is configured to allow requests from:
- Development: `http://localhost:3000`
- Production: Set via `CORS_ORIGIN` environment variable

---

## Future Enhancements

### 1. AI Integration
Replace stub `generateSummary()` with actual AI:
```typescript
// Example with OpenAI
const response = await openai.chat.completions.create({
  model: 'gpt-4',
  messages: [
    {
      role: 'system',
      content: 'You are a Quran scholar assistant.'
    },
    {
      role: 'user',
      content: `Based on these verses: ${verses}, answer: ${question}`
    }
  ]
});
```

### 2. Semantic Search
Use vector embeddings for better verse retrieval:
```typescript
// Generate embeddings for all verses
// Store in vector database (pgvector)
// Query by semantic similarity
```

### 3. Multi-language Support
Add support for more languages:
- English translations
- Arabic tafsir
- Other languages

### 4. Advanced Search
- Search by surah
- Search by juz
- Search by theme
- Full-text search

### 5. User Management
- User registration
- Authentication (JWT)
- User preferences
- Bookmarks/favorites

---

## Testing

### Manual Testing with cURL

Send a message:
```bash
curl -X POST http://localhost:3001/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Namaz neden önemlidir?"}'
```

Get conversations:
```bash
curl http://localhost:3001/api/conversations?userId=demo-user
```

### Automated Testing

Run tests:
```bash
cd backend
npm run test
```

---

## Database Schema

See `backend/prisma/schema.prisma` for complete schema definition.

**Tables:**
- `quran_verses`: Quran verses with translations
- `conversations`: User conversations
- `messages`: Individual messages

**Relationships:**
- One conversation has many messages
- Messages reference conversations (cascade delete)

---

## Support

For questions or issues:
1. Check the main README.md
2. Review backend/README.md
3. Check Prisma schema
4. Review service logic in `chat.service.ts`


