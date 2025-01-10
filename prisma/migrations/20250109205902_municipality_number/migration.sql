/*
  Warnings:

  - Added the required column `municipalityNumber` to the `Collective` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Collective" ADD COLUMN     "municipalityNumber" TEXT NOT NULL;
