#!/bin/bash

# Ayet Rehberi Installation Script
# This script automates the setup process for the Ayet Rehberi application

set -e  # Exit on error

echo "🚀 Ayet Rehberi Installation Script"
echo "===================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check Node.js
echo "📦 Checking prerequisites..."
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js 18 or higher.${NC}"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo -e "${RED}❌ Node.js version 18 or higher is required. Current: $(node -v)${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js $(node -v)${NC}"

# Check PostgreSQL
if ! command -v psql &> /dev/null; then
    echo -e "${YELLOW}⚠️  PostgreSQL command line tools not found.${NC}"
    echo "   Please ensure PostgreSQL is installed and running."
else
    echo -e "${GREEN}✓ PostgreSQL installed${NC}"
fi

echo ""

# Backend Setup
echo "🔧 Setting up backend..."
cd backend

if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${YELLOW}📝 Created backend/.env from .env.example${NC}"
        echo -e "${YELLOW}   Please edit backend/.env with your database credentials${NC}"
    else
        echo -e "${RED}❌ .env.example not found${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ backend/.env already exists${NC}"
fi

echo "📦 Installing backend dependencies..."
npm install

echo "🔨 Generating Prisma client..."
npx prisma generate

echo -e "${YELLOW}⚠️  Make sure PostgreSQL is running and backend/.env is configured${NC}"
echo ""
read -p "Press Enter to run database migrations (or Ctrl+C to exit)..."

echo "🗄️  Running database migrations..."
npx prisma migrate dev --name init || {
    echo -e "${RED}❌ Migration failed. Please check your database connection.${NC}"
    exit 1
}

echo "🌱 Seeding database..."
npm run seed

echo -e "${GREEN}✓ Backend setup complete!${NC}"
cd ..

echo ""

# Frontend Setup
echo "🎨 Setting up frontend..."
cd frontend

if [ ! -f ".env.local" ]; then
    if [ -f ".env.local.example" ]; then
        cp .env.local.example .env.local
        echo -e "${GREEN}✓ Created frontend/.env.local from .env.local.example${NC}"
    else
        echo "NEXT_PUBLIC_API_URL=http://localhost:3001/api" > .env.local
        echo -e "${GREEN}✓ Created frontend/.env.local${NC}"
    fi
else
    echo -e "${GREEN}✓ frontend/.env.local already exists${NC}"
fi

echo "📦 Installing frontend dependencies..."
npm install

echo -e "${GREEN}✓ Frontend setup complete!${NC}"
cd ..

echo ""
echo "✨ Installation Complete! ✨"
echo ""
echo "To start the application:"
echo ""
echo "Terminal 1 (Backend):"
echo "  cd backend"
echo "  npm run start:dev"
echo ""
echo "Terminal 2 (Frontend):"
echo "  cd frontend"
echo "  npm run dev"
echo ""
echo "Then open: http://localhost:3000"
echo ""
echo "Happy coding! 🚀"


