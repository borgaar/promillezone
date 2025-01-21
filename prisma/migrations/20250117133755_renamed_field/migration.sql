/*
  Warnings:

  - You are about to drop the column `userId` on the `CompletedChore` table. All the data in the column will be lost.
  - Added the required column `completedByUserId` to the `CompletedChore` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "CompletedChore" DROP CONSTRAINT "CompletedChore_userId_fkey";

-- AlterTable
ALTER TABLE "CompletedChore" DROP COLUMN "userId",
ADD COLUMN     "completedByUserId" TEXT NOT NULL;

-- AddForeignKey
ALTER TABLE "CompletedChore" ADD CONSTRAINT "CompletedChore_completedByUserId_fkey" FOREIGN KEY ("completedByUserId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
