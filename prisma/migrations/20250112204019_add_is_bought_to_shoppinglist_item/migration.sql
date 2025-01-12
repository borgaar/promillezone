/*
  Warnings:

  - Added the required column `isBought` to the `ShoppingListItem` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ShoppingListItem" ADD COLUMN     "isBought" BOOLEAN NOT NULL;
