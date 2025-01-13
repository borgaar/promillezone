import { ShoppingCart } from "lucide-react";
import { Card, CardHeader, CardTitle } from "../../ui/card";
import { AddToShoppingCartDialog } from "./add-to-shopping-cart-dialog";
import { Suspense } from "react";
import ShoppingListContent from "./content";

export default async function ShoppingTile() {
  return (
    <Card className="relative max-lg:row-start-3 lg:col-start-3 lg:row-start-1">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex gap-2">
            <ShoppingCart strokeWidth={2.5} /> Handleliste
          </span>
          <AddToShoppingCartDialog />
        </CardTitle>
      </CardHeader>
      <Suspense>
        <ShoppingListContent />
      </Suspense>
    </Card>
  );
}
