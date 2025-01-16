import { Suspense } from "react";
import { Card } from "../../ui/card";
import ShoppingListContent from "./content";

export default async function ShoppingTile() {
  return (
    <Card className="relative lg:col-start-2 lg:row-start-2">
      <Suspense>
        <ShoppingListContent />
      </Suspense>
    </Card>
  );
}
