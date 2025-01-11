/*
  Warnings:

  - You are about to drop the column `expiration` on the `JoinCollectiveToken` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "JoinCollectiveToken" DROP COLUMN "expiration",
ADD COLUMN     "expiresAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP + INTERVAL '24 hours';
