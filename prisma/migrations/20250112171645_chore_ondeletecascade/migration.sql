-- DropForeignKey
ALTER TABLE "DueChore" DROP CONSTRAINT "DueChore_ChoreId_fkey";

-- AlterTable
ALTER TABLE "JoinCollectiveToken" ALTER COLUMN "expiresAt" SET DEFAULT CURRENT_TIMESTAMP + INTERVAL '24 hours';

-- AddForeignKey
ALTER TABLE "DueChore" ADD CONSTRAINT "DueChore_ChoreId_fkey" FOREIGN KEY ("ChoreId") REFERENCES "Chore"("id") ON DELETE CASCADE ON UPDATE CASCADE;
