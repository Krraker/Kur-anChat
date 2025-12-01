# Quick Setup Guide

Follow these steps to get Ayet Rehberi up and running on your local machine.

## Prerequisites Check

```bash
node --version  # Should be 18 or higher
npm --version
psql --version  # PostgreSQL should be installed
```

## Step 1: Clone and Navigate

```bash
cd /path/to/KuranChat
```

## Step 2: Database Setup

1. Create PostgreSQL database:

```bash
# Log into PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE ayet_rehberi;

# Exit psql
\q
```

2. Update your database credentials in backend `.env` file

## Step 3: Backend Setup

```bash
# Navigate to backend
cd backend

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your database credentials

# Generate Prisma client
npx prisma generate

# Run migrations
npx prisma migrate dev --name init

# Seed the database
npm run seed

# Start backend server
npm run start:dev
```

Backend should now be running on `http://localhost:3001`

## Step 4: Frontend Setup

Open a new terminal window:

```bash
# Navigate to frontend
cd frontend

# Install dependencies
npm install

# Set up environment variables
cp .env.local.example .env.local

# Start development server
npm run dev
```

Frontend should now be running on `http://localhost:3000`

## Step 5: Test the Application

1. Open your browser and go to `http://localhost:3000`
2. Try asking a question like:
   - "Sabır hakkında ne diyor?"
   - "Namaz neden önemlidir?"
   - "Zorluklar hakkında ne söyler?"

## Troubleshooting

### Backend Issues

**Database connection failed:**
- Check PostgreSQL is running: `pg_isready`
- Verify DATABASE_URL in `.env` is correct
- Ensure database exists: `psql -U postgres -l`

**Port 3001 already in use:**
- Change PORT in backend `.env`
- Update NEXT_PUBLIC_API_URL in frontend `.env.local`

### Frontend Issues

**Cannot connect to backend:**
- Ensure backend is running on correct port
- Check NEXT_PUBLIC_API_URL in `.env.local`
- Check browser console for CORS errors

**Styles not loading:**
```bash
cd frontend
npm run build
npm run dev
```

## Next Steps

### Adding More Quran Verses

The seed file includes only sample verses. To add the complete Quran:

1. Obtain a Quran dataset (JSON format)
2. Update `backend/prisma/seed.ts`
3. Run: `npm run seed`

### Integrating AI

The `generateSummary()` function in `backend/src/chat/chat.service.ts` is a stub. To add AI:

1. Choose a provider (OpenAI, Anthropic, etc.)
2. Add credentials to `.env`:
   ```
   OPENAI_API_KEY=your_key_here
   ```
3. Install SDK:
   ```bash
   npm install openai
   ```
4. Implement the function in `chat.service.ts`

### Deployment

**Backend (Railway/Render):**
1. Create a PostgreSQL database
2. Set environment variables
3. Deploy from GitHub
4. Run migrations

**Frontend (Vercel):**
1. Import from GitHub
2. Set NEXT_PUBLIC_API_URL
3. Deploy

## Development Commands

### Backend
```bash
npm run start:dev  # Development mode
npm run build      # Build for production
npm run start:prod # Run production build
npm run seed       # Seed database
```

### Frontend
```bash
npm run dev        # Development mode
npm run build      # Build for production
npm run start      # Run production build
npm run lint       # Lint code
```

## File Structure Overview

```
KuranChat/
├── backend/
│   ├── prisma/
│   │   ├── schema.prisma    # Database schema
│   │   └── seed.ts          # Database seeding
│   └── src/
│       ├── chat/            # Chat logic
│       ├── prisma/          # Prisma service
│       └── main.ts          # Entry point
├── frontend/
│   └── src/
│       ├── app/             # Next.js pages
│       ├── components/      # React components
│       ├── services/        # API calls
│       └── types/           # TypeScript types
└── README.md
```

## Support

For issues or questions, check:
- Backend logs: `backend/` terminal
- Frontend logs: Browser console
- Database: `psql -U postgres -d ayet_rehberi`

Happy coding! 🚀


