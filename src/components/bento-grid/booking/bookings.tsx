"use client";

import { api } from "../../../trpc/react";
import { formatDate } from "date-fns";
import { nb } from "date-fns/locale";
import { useSession } from "next-auth/react";
import { Button } from "../../ui/button";
import { Trash } from "lucide-react";

export default function Bookings() {
  const utils = api.useUtils();
  const { data: bookings } = api.roomRouter.getRoomBookings.useQuery();
  const { mutateAsync: remove } = api.roomRouter.removeRoomBooking.useMutation({
    onMutate: async (id) => {
      // Cancel any outgoing refetches
      // (so they don't overwrite our optimistic update)
      await utils.roomRouter.getRoomBookings.cancel();

      const previous = utils.roomRouter.getRoomBookings.getData();

      if (!previous) return;

      const updated = previous.filter((i) => i.id !== id);

      utils.roomRouter.getRoomBookings.setData(undefined, updated);

      return { previous };
    },
    onError: (_error, _newItem, context) => {
      utils.roomRouter.getRoomBookings.setData(undefined, context?.previous);
    },
    onSettled: () => {
      void utils.roomRouter.getRoomBookings.invalidate();
    },
  });
  const { data } = useSession();

  return (
    <>
      {bookings?.map((b) => (
        <div
          key={b.id}
          className="flex w-full items-center space-x-4 rounded-lg border bg-white px-4 py-2 shadow-sm dark:bg-neutral-900"
        >
          <div className="flex-1">
            <p className="text-md font-medium text-gray-900 dark:text-gray-100">
              {formatDate(b.date, "EEEE dd.MM", { locale: nb })} av{" "}
              {b.booker.name}
            </p>
          </div>

          {b.booker.id === data?.user.id && (
            <Button
              size={"icon"}
              variant={"outline"}
              onClick={() => remove(b.id)}
            >
              <Trash />
            </Button>
          )}
        </div>
      ))}
    </>
  );
}
