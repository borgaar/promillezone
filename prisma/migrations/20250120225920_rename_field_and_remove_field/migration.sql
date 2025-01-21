/*
  Warnings:

  - You are about to drop the column `houseNumber` on the `Collective` table. All the data in the column will be lost.
  - You are about to drop the column `streetName` on the `Collective` table. All the data in the column will be lost.
  - Added the required column `postalCity` to the `Collective` table without a default value. This is not possible if the table is not empty.
  - Added the required column `streetAddress` to the `Collective` table without a default value. This is not possible if the table is not empty.
  - Made the column `coordinates` on table `Collective` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
-- THIS MIGRATION HAS BEEN MANUALLY EDITED
ALTER TABLE "Collective" DROP COLUMN "houseNumber";
ALTER TABLE "Collective" RENAME COLUMN "streetName" TO "streetAddress";
ALTER TABLE "Collective" ADD COLUMN "postalCity" TEXT NOT NULL;
ALTER TABLE "Collective" ALTER COLUMN "coordinates" SET NOT NULL;
