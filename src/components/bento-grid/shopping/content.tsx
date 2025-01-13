"use client";

import { useMemo } from "react";
import { api, type RouterOutputs } from "../../../trpc/react";
import { Button } from "../../ui/button";
import { CardContent, CardHeader, CardTitle } from "../../ui/card";
import { AddItemDialog } from "./add-item-dialog";
import ShoppingListItem from "./item";
import { ShoppingCart, Trash } from "lucide-react";

export type ShoppingListItem =
  RouterOutputs["shoppingList"]["getShoppingList"][number];

export default function ShoppingListContent() {
  const { data: items, refetch } = api.shoppingList.getShoppingList.useQuery();
  const utils = api.useUtils();

  const { mutateAsync: removeItems } =
    api.shoppingList.removeCheckedItems.useMutation({
      onMutate: async () => {
        // Cancel any outgoing refetches
        // (so they don't overwrite our optimistic update)
        await utils.shoppingList.getShoppingList.cancel();

        const previous = utils.shoppingList.getShoppingList.getData();

        if (!previous) return;

        const updated = previous.filter((i) => !i.isBought);

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

  const removeChecked = async () => {
    await removeItems();
    await refetch();
  };

  const canRemoveChecked = useMemo(
    () => Boolean(items?.some((i) => i.isBought)),
    [items],
  );

  return (
    <>
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex gap-2">
            <ShoppingCart strokeWidth={2.5} /> Handleliste
          </span>
          <div className="flex w-full items-center justify-end gap-2">
            <Button
              variant={"outline"}
              onClick={removeChecked}
              disabled={!canRemoveChecked}
            >
              <Trash />
              Fjern avhuket
            </Button>
            <AddItemDialog onComplete={refetch} />
          </div>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {Boolean(items) &&
          items!.map((item) => (
            <ShoppingListItem
              key={item.item + item.createdAt.toISOString()}
              item={item}
            />
          ))}
      </CardContent>
    </>
  );
}
