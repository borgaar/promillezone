/*
  Warnings:

  - The primary key for the `JoinCollectiveToken` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `id` on the `JoinCollectiveToken` table. All the data in the column will be lost.
  - The required column `token` was added to the `JoinCollectiveToken` table with a prisma-level default value. This is not possible if the table is not empty. Please add this column as optional, then populate it before making it required.

*/
-- AlterTable
ALTER TABLE "JoinCollectiveToken" DROP CONSTRAINT "JoinCollectiveToken_pkey",
DROP COLUMN "id",
ADD COLUMN     "token" TEXT NOT NULL,
ALTER COLUMN "expiration" SET DEFAULT CURRENT_TIMESTAMP + INTERVAL '24 hours',
ADD CONSTRAINT "JoinCollectiveToken_pkey" PRIMARY KEY ("token");
