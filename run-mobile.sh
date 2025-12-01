#!/bin/bash

# Ayet Rehberi - Flutter Mobile App Starter Script

echo "🚀 Ayet Rehberi Mobile App Starter"
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed.${NC}"
    echo "Please install Flutter: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo -e "${GREEN}✓ Flutter $(flutter --version | head -n 1)${NC}"
echo ""

# Check if in mobile directory
if [ ! -f "pubspec.yaml" ]; then
    echo "📂 Navigating to mobile directory..."
    cd mobile
fi

# Install dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Check backend
echo "🔍 Checking backend connection..."
echo -e "${YELLOW}⚠️  Make sure backend is running on http://localhost:3001${NC}"
echo ""

# List available devices
echo "📱 Available devices:"
flutter devices

echo ""
echo "Starting Flutter app..."
echo ""

# Run Flutter app
flutter run

# If Flutter run fails
if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}❌ Failed to start Flutter app${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "1. Make sure backend is running: cd backend && npm run start:dev"
    echo "2. Check backend URL in lib/services/api_service.dart"
    echo "3. For Android emulator, use: http://10.0.2.2:3001/api"
    echo "4. For iOS simulator, use: http://localhost:3001/api"
    echo "5. For physical device, use your computer's IP address"
    exit 1
fi


