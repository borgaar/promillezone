/*
  Warnings:

  - Added the required column `choreDueAt` to the `CompletedChore` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "CompletedChore" ADD COLUMN     "choreDueAt" TIMESTAMP(3) NOT NULL;
