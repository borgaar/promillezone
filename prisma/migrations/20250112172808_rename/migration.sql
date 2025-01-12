/*
  Warnings:

  - You are about to drop the column `ChoreId` on the `DueChore` table. All the data in the column will be lost.
  - Added the required column `choreId` to the `DueChore` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "DueChore" DROP CONSTRAINT "DueChore_ChoreId_fkey";

-- AlterTable
ALTER TABLE "DueChore" DROP COLUMN "ChoreId",
ADD COLUMN     "choreId" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "JoinCollectiveToken" ALTER COLUMN "expiresAt" SET DEFAULT CURRENT_TIMESTAMP + INTERVAL '24 hours';

-- AddForeignKey
ALTER TABLE "DueChore" ADD CONSTRAINT "DueChore_choreId_fkey" FOREIGN KEY ("choreId") REFERENCES "Chore"("id") ON DELETE CASCADE ON UPDATE CASCADE;
