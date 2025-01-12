/*
  Warnings:

  - The primary key for the `DueChore` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `id` on the `DueChore` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "DueChore" DROP CONSTRAINT "DueChore_pkey",
DROP COLUMN "id",
ADD CONSTRAINT "DueChore_pkey" PRIMARY KEY ("dueDate", "choreId");

-- AlterTable
ALTER TABLE "JoinCollectiveToken" ALTER COLUMN "expiresAt" SET DEFAULT CURRENT_TIMESTAMP + INTERVAL '24 hours';
