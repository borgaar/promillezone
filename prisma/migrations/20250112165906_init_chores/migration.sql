-- AlterTable
ALTER TABLE "JoinCollectiveToken" ALTER COLUMN "expiresAt" SET DEFAULT CURRENT_TIMESTAMP + INTERVAL '24 hours';

-- CreateTable
CREATE TABLE "Chore" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "collectiveId" TEXT NOT NULL,
    "frequency" INTEGER NOT NULL,

    CONSTRAINT "Chore_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DueChore" (
    "id" TEXT NOT NULL,
    "ChoreId" TEXT NOT NULL,
    "assigneeId" TEXT NOT NULL,
    "dueDate" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DueChore_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "Chore" ADD CONSTRAINT "Chore_collectiveId_fkey" FOREIGN KEY ("collectiveId") REFERENCES "Collective"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DueChore" ADD CONSTRAINT "DueChore_ChoreId_fkey" FOREIGN KEY ("ChoreId") REFERENCES "Chore"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DueChore" ADD CONSTRAINT "DueChore_assigneeId_fkey" FOREIGN KEY ("assigneeId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
