"use server";

import { type RouterOutputs } from "../../../trpc/react";
import { CardContent } from "../../ui/card";
import { api } from "../../../trpc/server";
import ShoppingListItem from "./item";

export type Item = RouterOutputs["shoppingList"]["getShoppingList"][number];

export default async function ShoppingListContent() {
  const items = await api.shoppingList.getShoppingList();

  return (
    <CardContent className="space-y-4">
      {items.map((item) => (
        <ShoppingListItem key={item.item} item={item} />
      ))}
    </CardContent>
  );
}
