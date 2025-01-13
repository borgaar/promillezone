/*
  Warnings:

  - Added the required column `createdBy` to the `ShoppingListItem` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `ShoppingListItem` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ShoppingListItem" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "createdBy" TEXT NOT NULL,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL;

-- AddForeignKey
ALTER TABLE "ShoppingListItem" ADD CONSTRAINT "ShoppingListItem_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
