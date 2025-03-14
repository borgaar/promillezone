-- CreateTable
CREATE TABLE "BusStop" (
    "id" TEXT NOT NULL,
    "coordinates" TEXT NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "BusStop_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CollectiveBusStop" (
    "collectiveId" TEXT NOT NULL,
    "busStopId" TEXT NOT NULL,

    CONSTRAINT "CollectiveBusStop_pkey" PRIMARY KEY ("collectiveId","busStopId")
);

-- CreateIndex
CREATE UNIQUE INDEX "CollectiveBusStop_collectiveId_busStopId_key" ON "CollectiveBusStop"("collectiveId", "busStopId");

-- AddForeignKey
ALTER TABLE "CollectiveBusStop" ADD CONSTRAINT "CollectiveBusStop_collectiveId_fkey" FOREIGN KEY ("collectiveId") REFERENCES "Collective"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CollectiveBusStop" ADD CONSTRAINT "CollectiveBusStop_busStopId_fkey" FOREIGN KEY ("busStopId") REFERENCES "BusStop"("id") ON DELETE CASCADE ON UPDATE CASCADE;
