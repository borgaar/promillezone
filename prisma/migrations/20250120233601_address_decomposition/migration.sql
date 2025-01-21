/*
  Warnings:

  - You are about to drop the column `streetAddress` on the `Collective` table. All the data in the column will be lost.
  - Added the required column `streetName` to the `Collective` table without a default value. This is not possible if the table is not empty.
  - Added the required column `streetNumber` to the `Collective` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
-- THIS MIGRATION HAS BEEN MANUALLY EDITED
ALTER TABLE "Collective" RENAME COLUMN "streetAddress" TO "streetName";

ALTER TABLE "Collective" 
ADD COLUMN     "streetLetter" TEXT,
ADD COLUMN     "streetNumber" TEXT NOT NULL;
