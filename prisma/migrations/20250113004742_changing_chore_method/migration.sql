/*
  Warnings:

  - You are about to drop the column `name` on the `Chore` table. All the data in the column will be lost.
  - You are about to drop the `DueChore` table. If the table is not empty, all the data it contains will be lost.
  - A unique constraint covering the columns `[collectiveId,description]` on the table `Chore` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `description` to the `Chore` table without a default value. This is not possible if the table is not empty.
  - Added the required column `startingDate` to the `Chore` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "DueChore" DROP CONSTRAINT "DueChore_assigneeId_fkey";

-- DropForeignKey
ALTER TABLE "DueChore" DROP CONSTRAINT "DueChore_choreId_fkey";

-- AlterTable
ALTER TABLE "Chore" DROP COLUMN "name",
ADD COLUMN     "description" TEXT NOT NULL,
ADD COLUMN     "startingDate" TIMESTAMP(3) NOT NULL;

-- DropTable
DROP TABLE "DueChore";

-- CreateTable
CREATE TABLE "CompletedChore" (
    "id" TEXT NOT NULL,
    "choreId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "completedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CompletedChore_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Chore_collectiveId_description_key" ON "Chore"("collectiveId", "description");

-- AddForeignKey
ALTER TABLE "CompletedChore" ADD CONSTRAINT "CompletedChore_choreId_fkey" FOREIGN KEY ("choreId") REFERENCES "Chore"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CompletedChore" ADD CONSTRAINT "CompletedChore_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
