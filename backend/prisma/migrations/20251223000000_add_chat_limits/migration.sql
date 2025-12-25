-- AlterTable
-- Add chat usage tracking fields to users table
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "daily_message_count" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "daily_message_reset_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "is_premium" BOOLEAN NOT NULL DEFAULT false;

