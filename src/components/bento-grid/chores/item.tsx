"use client";

import { api, type RouterOutputs } from "../../../trpc/react";
import { Checkbox } from "../../ui/checkbox";
import { useEffect } from "react";
import { type ChoreItem } from "./content";
import { EditChoreDialog } from "./edit-chore-dialog";

export default function ChoreItem({ chore }: { chore: ChoreItem }) {
  const utils = api.useUtils();
  const { mutateAsync: toggle, status } =
    api.shoppingList.toggleItemBoughtState.useMutation({
      onMutate: async (newItem) => {
        // Cancel any outgoing refetches
        // (so they don't overwrite our optimistic update)
        await utils.shoppingList.getShoppingList.cancel();

        const previous = utils.shoppingList.getShoppingList.getData();

        if (!previous) return;

        const updated = previous.map((item) => {
          if (item.item === newItem) {
            return {
              ...item,
              isBought: !item.isBought,
            };
          }

          return item;
        });

        utils.shoppingList.getShoppingList.setData(undefined, updated);

        return { previous };
      },
      onError: (_error, _newItem, context) => {
        utils.shoppingList.getShoppingList.setData(
          undefined,
          context?.previous,
        );
      },
      onSettled: () => {
        void utils.shoppingList.getShoppingList.invalidate();
      },
    });

  useEffect(() => {
    console.log(status);
  }, [status]);

  return (
    <div className="flex w-full items-center space-x-4 rounded-lg border bg-white px-4 py-2 shadow-sm dark:bg-neutral-900">
      {/* <Checkbox
        className="h-5 w-5"
        checked={item.isBought}
        onCheckedChange={() => toggle(item.item)}
      /> */}

      <div className="flex-1">
        <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
          {chore.description}
        </p>
      </div>

      <EditChoreDialog chore={chore} />
    </div>
  );
}
