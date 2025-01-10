-- AlterTable
ALTER TABLE "JoinCollectiveToken" ALTER COLUMN "expiration" SET DEFAULT CURRENT_TIMESTAMP + INTERVAL '24 hours';
