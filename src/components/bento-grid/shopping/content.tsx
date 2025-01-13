"use client";

import { api, type RouterOutputs } from "../../../trpc/react";
import { CardContent, CardHeader, CardTitle } from "../../ui/card";
import ShoppingListItem from "./item";
import { ShoppingCart } from "lucide-react";
import { AddToShoppingCartDialog } from "./add-to-shopping-cart-dialog";

export type Item = RouterOutputs["shoppingList"]["getShoppingList"][number];

export default function ShoppingListContent() {
  const {
    data: items,
    isLoading,
    refetch,
  } = api.shoppingList.getShoppingList.useQuery();

  return (
    <>
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex gap-2">
            <ShoppingCart strokeWidth={2.5} /> Handleliste
          </span>
          <AddToShoppingCartDialog onComplete={refetch} />
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {isLoading ? (
          <div>Laster...</div>
        ) : (
          items!.map((item) => <ShoppingListItem key={item.item} item={item} />)
        )}
      </CardContent>
    </>
  );
}
