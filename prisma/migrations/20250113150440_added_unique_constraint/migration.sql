/*
  Warnings:

  - A unique constraint covering the columns `[date,collectiveId]` on the table `RoomBooking` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "RoomBooking_date_collectiveId_key" ON "RoomBooking"("date", "collectiveId");
