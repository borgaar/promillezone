"use client";

import { Trash } from "lucide-react";
import { api } from "../../../trpc/react";
import { formatDate } from "date-fns";
import { nb } from "date-fns/locale";

export default function Bookings() {
  const { data: bookings } = api.roomRouter.getRoomBookings.useQuery();

  return (
    <>
      {bookings?.map((b) => (
        <div
          key={b.id}
          className="flex w-full items-center space-x-4 rounded-lg border bg-white px-4 py-2 shadow-sm dark:bg-neutral-900"
        >
          <div className="flex-1">
            <p className="text-md font-medium text-gray-900 dark:text-gray-100">
              {formatDate(b.date, "dd.MM", { locale: nb })} av {b.booker.name}
            </p>
          </div>
        </div>
      ))}
    </>
  );
}
