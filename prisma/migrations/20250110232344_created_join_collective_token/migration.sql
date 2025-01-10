-- CreateTable
CREATE TABLE "JoinCollectiveToken" (
    "id" TEXT NOT NULL,
    "expiration" TIMESTAMP(3) NOT NULL,
    "createdBy" TEXT NOT NULL,
    "collectiveId" TEXT NOT NULL,

    CONSTRAINT "JoinCollectiveToken_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "JoinCollectiveToken" ADD CONSTRAINT "JoinCollectiveToken_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JoinCollectiveToken" ADD CONSTRAINT "JoinCollectiveToken_collectiveId_fkey" FOREIGN KEY ("collectiveId") REFERENCES "Collective"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
