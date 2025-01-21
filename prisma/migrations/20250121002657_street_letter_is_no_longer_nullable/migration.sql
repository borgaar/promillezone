/*
  Warnings:

  - Made the column `streetLetter` on table `Collective` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "Collective" ALTER COLUMN "streetLetter" SET NOT NULL;
