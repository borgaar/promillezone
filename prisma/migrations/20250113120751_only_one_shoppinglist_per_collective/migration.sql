/*
  Warnings:

  - The primary key for the `ShoppingListItem` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `shoppingListId` on the `ShoppingListItem` table. All the data in the column will be lost.
  - You are about to drop the `ShoppingList` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `collectiveId` to the `ShoppingListItem` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "ShoppingList" DROP CONSTRAINT "ShoppingList_owner_fkey";

-- DropForeignKey
ALTER TABLE "ShoppingListItem" DROP CONSTRAINT "ShoppingListItem_shoppingListId_fkey";

-- AlterTable
ALTER TABLE "ShoppingListItem" DROP CONSTRAINT "ShoppingListItem_pkey",
DROP COLUMN "shoppingListId",
ADD COLUMN     "collectiveId" TEXT NOT NULL,
ADD CONSTRAINT "ShoppingListItem_pkey" PRIMARY KEY ("collectiveId", "item");

-- DropTable
DROP TABLE "ShoppingList";

-- AddForeignKey
ALTER TABLE "ShoppingListItem" ADD CONSTRAINT "ShoppingListItem_collectiveId_fkey" FOREIGN KEY ("collectiveId") REFERENCES "Collective"("id") ON DELETE CASCADE ON UPDATE CASCADE;
