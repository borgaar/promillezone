-- DropForeignKey
ALTER TABLE "User" DROP CONSTRAINT "User_collectiveId_fkey";

-- AlterTable
ALTER TABLE "User" ALTER COLUMN "collectiveId" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_collectiveId_fkey" FOREIGN KEY ("collectiveId") REFERENCES "Collective"("id") ON DELETE SET NULL ON UPDATE CASCADE;
