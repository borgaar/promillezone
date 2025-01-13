"use client";

import { Button } from "@/components/ui/button";
import { Edit } from "lucide-react";
import { api, type RouterOutputs } from "../../../trpc/react";
import { Checkbox } from "../../ui/checkbox";
import { useRouter } from "next/navigation";

export default function ShoppingListItem({
  item,
}: {
  item: RouterOutputs["shoppingList"]["getShoppingList"][number];
}) {
  const { mutateAsync: toggle, isPending } =
    api.shoppingList.toggleItemBoughtState.useMutation();
  const router = useRouter();

  return (
    <div className="flex w-full items-center space-x-4 rounded-lg border bg-white p-4 shadow-sm dark:bg-neutral-900">
      <div className="flex-1">
        <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
          {item.item}
        </p>
        {/* <p className="text-xs text-gray-500 dark:text-neutral-300">
          {user.}
        </p> */}
      </div>

      <Checkbox
        checked={isPending ? !item.isBought : item.isBought}
        onCheckedChange={async () => {
          await toggle(item.item);
          router.refresh();
        }}
      />

      <Button variant="outline" size="icon">
        <Edit />
      </Button>
    </div>
  );
}
