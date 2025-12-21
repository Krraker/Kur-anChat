# 🚀 Backend Deployment Guide

> Deploy your NestJS backend to Railway (easiest option for this stack).

---

## Option Comparison

| Platform | Ease | Cost | Best For |
|----------|------|------|----------|
| **Railway** | ⭐⭐⭐⭐⭐ | $5-20/mo | This project |
| Render | ⭐⭐⭐⭐ | $7-25/mo | Alternative |
| Fly.io | ⭐⭐⭐ | $5-15/mo | Advanced users |
| Heroku | ⭐⭐⭐⭐ | $7-25/mo | Legacy choice |
| AWS/GCP | ⭐⭐ | Varies | Enterprise |

**Recommendation:** Use Railway. It's the easiest for NestJS + PostgreSQL.

---

## Railway Deployment

### Step 1: Create Account

1. Go to https://railway.app
2. Sign up with GitHub (recommended)
3. You get $5 free credit to start

### Step 2: Create New Project

1. Click "New Project"
2. Choose "Deploy from GitHub repo"
3. Select your `KuranChat` repository
4. Railway will auto-detect it's a Node.js project

### Step 3: Add PostgreSQL Database

1. In your project, click "New"
2. Select "Database" → "PostgreSQL"
3. Railway creates a database instantly
4. Click on the database → "Variables" tab
5. Copy the `DATABASE_URL`

### Step 4: Configure Backend Service

1. Click on your backend service
2. Go to "Settings" tab
3. Set:
   - **Root Directory:** `backend`
   - **Build Command:** `npm run build`
   - **Start Command:** `npm run start:prod`

4. Go to "Variables" tab and add:

```
DATABASE_URL=<paste from PostgreSQL>
OPENAI_API_KEY=<your OpenAI key>
NODE_ENV=production
PORT=3000
```

### Step 5: Deploy

1. Railway auto-deploys on push to main branch
2. Or click "Deploy" button manually
3. Wait for build to complete (2-3 minutes)

### Step 6: Run Migrations

1. In Railway, click on backend service
2. Go to "Settings" → "Deploy" section
3. Add a one-time deploy command:

```bash
npx prisma migrate deploy && npm run start:prod
```

Or use Railway CLI:

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Link to your project
railway link

# Run migrations
railway run npx prisma migrate deploy

# Seed Quran data (if not already done)
railway run npx ts-node scripts/import-quran.ts
```

### Step 7: Get Your API URL

1. In Railway, click on backend service
2. Go to "Settings" → "Networking"
3. Click "Generate Domain"
4. You'll get something like: `kuranchat-backend.up.railway.app`

---

## Update Mobile App

### Update API Config

Edit `mobile/lib/services/api_config.dart`:

```dart
class ApiConfig {
  // Development
  static const String devBaseUrl = 'http://localhost:3000';
  
  // Production - UPDATE THIS!
  static const String prodBaseUrl = 'https://kuranchat-backend.up.railway.app';
  
  // Use this in your app
  static String get baseUrl {
    // For release builds, use production
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? prodBaseUrl : devBaseUrl;
  }
}
```

### Test Production API

```bash
# Test the API is working
curl https://kuranchat-backend.up.railway.app/api/daily

# Should return verse of the day
```

---

## Verify Deployment

### Check API Endpoints

```bash
# Daily content
curl https://YOUR-URL.up.railway.app/api/daily

# Quran stats
curl https://YOUR-URL.up.railway.app/api/quran/stats

# Get a surah
curl https://YOUR-URL.up.railway.app/api/quran/surah/1
```

### Check Database

```bash
# Connect via Railway CLI
railway run npx prisma studio

# Opens Prisma Studio in browser
# Verify QuranVerse table has 6,236 rows
```

---

## Railway Costs Breakdown

| Resource | Usage | Cost |
|----------|-------|------|
| Backend (NestJS) | ~512MB RAM | ~$5/mo |
| PostgreSQL | 1GB storage | ~$5/mo |
| **Total** | | **~$10/mo** |

Scales with usage. Free tier covers development.

---

## Environment Variables Checklist

| Variable | Required | Where to Get |
|----------|----------|--------------|
| `DATABASE_URL` | ✅ | Railway PostgreSQL |
| `OPENAI_API_KEY` | ✅ | platform.openai.com |
| `NODE_ENV` | ✅ | Set to `production` |
| `PORT` | ⚠️ | Usually auto-set |
| `REVENUECAT_SECRET` | Optional | For server-side receipt validation |

---

## Troubleshooting

### Build Fails
```bash
# Check logs in Railway dashboard
# Common issues:
# - Wrong root directory (should be 'backend')
# - Missing dependencies
# - TypeScript errors
```

### Database Connection Fails
```bash
# Verify DATABASE_URL is correct
# Check PostgreSQL is running in Railway
# Ensure migrations ran successfully
```

### API Returns 500 Errors
```bash
# Check Railway logs for errors
# Verify environment variables are set
# Check OpenAI API key is valid
```

### Quran Data Missing
```bash
# Run import script via Railway CLI
railway run npx ts-node scripts/import-quran.ts
```

---

## Monitoring

Railway provides built-in:
- Logs viewer
- Memory/CPU metrics
- Deploy history
- Automatic HTTPS

For production, consider adding:
- Sentry for error tracking
- LogDNA/Papertrail for log management

---

## Alternative: Render

If Railway doesn't work for you:

1. Go to https://render.com
2. Create Web Service from GitHub
3. Create PostgreSQL database
4. Similar setup process

---

*Backend is deployed when you can curl your API and get Quran data!*



