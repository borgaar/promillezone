/*
  Warnings:

  - You are about to drop the column `address` on the `Collective` table. All the data in the column will be lost.
  - Added the required column `houseNumber` to the `Collective` table without a default value. This is not possible if the table is not empty.
  - Added the required column `streetName` to the `Collective` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Collective" DROP COLUMN "address",
ADD COLUMN     "houseNumber" INTEGER NOT NULL,
ADD COLUMN     "streetName" TEXT NOT NULL;
