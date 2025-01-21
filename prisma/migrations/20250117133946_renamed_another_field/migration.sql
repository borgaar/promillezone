/*
  Warnings:

  - You are about to drop the column `choreDueAt` on the `CompletedChore` table. All the data in the column will be lost.
  - Added the required column `choreWasDueAt` to the `CompletedChore` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "CompletedChore" DROP COLUMN "choreDueAt",
ADD COLUMN     "choreWasDueAt" TIMESTAMP(3) NOT NULL;
