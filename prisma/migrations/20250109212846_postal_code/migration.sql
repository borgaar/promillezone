/*
  Warnings:

  - You are about to drop the column `municipalityNumber` on the `Collective` table. All the data in the column will be lost.
  - Added the required column `postalCode` to the `Collective` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Collective" DROP COLUMN "municipalityNumber",
ADD COLUMN     "postalCode" TEXT NOT NULL;
