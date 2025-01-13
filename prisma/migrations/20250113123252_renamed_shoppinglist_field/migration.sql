/*
  Warnings:

  - You are about to drop the column `createdBy` on the `ShoppingListItem` table. All the data in the column will be lost.
  - Added the required column `createdById` to the `ShoppingListItem` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "ShoppingListItem" DROP CONSTRAINT "ShoppingListItem_createdBy_fkey";

-- AlterTable
ALTER TABLE "ShoppingListItem" DROP COLUMN "createdBy",
ADD COLUMN     "createdById" TEXT NOT NULL;

-- AddForeignKey
ALTER TABLE "ShoppingListItem" ADD CONSTRAINT "ShoppingListItem_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
