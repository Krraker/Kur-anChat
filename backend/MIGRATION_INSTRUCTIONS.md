# Database Migration Instructions

## Step 1: Generate Migration

After updating the schema, run this command:

```bash
cd backend
npx prisma migrate dev --name add_chat_limits
```

This will:
1. Generate migration SQL file
2. Apply it to your database
3. Update Prisma Client

## Step 2: Verify Migration

Check that the migration was created:

```bash
ls prisma/migrations/
```

You should see a new folder with timestamp like: `20241223_add_chat_limits/`

## Step 3: Generate Prisma Client

```bash
npx prisma generate
```

## For Production (Railway)

After deploying, run:

```bash
npx prisma migrate deploy
```

Or set this as a build command in Railway.

## Rollback (if needed)

```bash
npx prisma migrate reset
```

⚠️ WARNING: This will delete all data!

---

**Note:** Run these commands AFTER deploying to Railway, or run locally if testing first.

